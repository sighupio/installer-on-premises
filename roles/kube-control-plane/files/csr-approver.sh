#!/bin/bash
set -euo pipefail
export KUBECONFIG="kubeconfig.yaml"

# CSR Auto-Approval Script for Kubernetes CronJob
# This script approves kubelet-serving CSRs for nodes that exist in the cluster
 
# Configuration
LOG_LEVEL="${LOG_LEVEL:-info}"
DRY_RUN="${DRY_RUN:-false}"
 
# Help function
show_help() {
    cat << EOF
CSR Auto-Approval Script for Kubernetes
 
DESCRIPTION:
    This script automatically approves kubelet-serving CSRs for nodes that exist in the cluster.
    It validates that the CSR is for kubelet serving certificates and that the requesting node
    is actually joined to the cluster before approval.
 
USAGE:
    $0 [OPTIONS]
 
OPTIONS:
    -h, --help      Show this help message and exit
    -d, --dry-run   Run in dry-run mode (show what would be done without making changes)
    -v, --verbose   Enable debug logging
    -q, --quiet     Only show errors and warnings
 
ENVIRONMENT VARIABLES:
    LOG_LEVEL       Set log level (debug, info, warn, error) [default: info]
    DRY_RUN         Enable dry-run mode (true/false) [default: false]
 
EXAMPLES:
    # Normal operation
    $0
 
    # Dry run to see what would be approved
    $0 --dry-run
 
    # Debug mode with verbose logging
    $0 --verbose
 
    # Run with environment variables
    LOG_LEVEL=debug DRY_RUN=true $0
 
    # Run in a Kubernetes CronJob
    kubectl create cronjob csr-approver --image=busybox --schedule="*/5 * * * *" \\
      --restart=OnFailure -- /bin/sh -c "curl -s https://path/to/cronjob.sh | bash"
 
REQUIREMENTS:
    - kubectl (configured with appropriate RBAC permissions)
    - jq (for JSON parsing)
    - Kubernetes cluster access
 
RBAC REQUIREMENTS:
    - certificates.k8s.io/certificatesigningrequests: get, list, update, patch
    - core/nodes: get, list
 
BEHAVIOR:
    1. Lists all pending CSRs in the cluster
    2. Filters for kubelet-serving CSRs only
    3. Extracts node name from CSR subject (system:node:<nodename>)
    4. Validates that the node exists in the cluster
    5. Approves CSRs for valid, existing nodes (any status: Ready/NotReady/Unknown)
    6. Skips CSRs that don't match criteria (no denial, just logs and moves on)
 
EXIT CODES:
    0   Success
    1   Error (missing tools, invalid arguments, etc.)
 
EOF
}
 
# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -v|--verbose)
                LOG_LEVEL="debug"
                shift
                ;;
            -q|--quiet)
                LOG_LEVEL="warn"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}
 
# Logging functions
log_info() {
    # Info logs shown if LOG_LEVEL is not 'warn' or 'error'
    if [[ "$LOG_LEVEL" != "warn" && "$LOG_LEVEL" != "error" ]]; then
        echo "[$(date -Iseconds)] INFO: $*"
    fi
}
 
log_warn() {
    echo "[$(date -Iseconds)] WARN: $*"
}
 
log_error() {
    echo "[$(date -Iseconds)] ERROR: $*" >&2
}
 
log_debug() {
    if [[ "$LOG_LEVEL" == "debug" ]]; then
        echo "[$(date -Iseconds)] DEBUG: $*"
    fi
}
 
# Check required tools
check_prerequisites() {
    local missing_tools=()
    
    if ! command -v kubectl >/dev/null 2>&1; then
        missing_tools+=("kubectl")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_tools+=("jq")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    
    log_debug "Prerequisites check passed"
}
 
# Extract node name from CSR subject (the CSR's username field should be 'system:node:<nodeName>')
extract_node_name() {
    local csr_name="$1"
    local username
    
    username=$(kubectl get csr "$csr_name" -o jsonpath='{.spec.username}' 2>/dev/null)
    log_debug "username for $csr_name: $username" >&2
    if [[ -z "$username" ]]; then
        log_error "Could not extract username from CSR $csr_name"
        return 1
    fi
    
    # Username expected format: system:node:<NODE_NAME>
    if [[ "$username" =~ ^system:node:(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        log_error "Username '$username' does not match 'system:node:*' pattern"
        return 1
    fi
}
 
# Extract and check subj altnames from CSR
check_subj_altnames() {
 
    local csr_name="$1"
    local node_name="$2"
    local check_result=0
 
    # Extract all subj altnames from CSR in a single line, removing whitespaces between commas
    local csr_altnames=$(kubectl get csr -o jsonpath={.spec.request} $csr_name | base64 -d | openssl req -noout -text 2>/dev/null  | grep -A1 "X509v3 Subject Alternative Name" | tail -n 1 | sed -e "s/^ *//g" -e "s/, / /g" -e "s/IP Address:/IPAddress:/g" )
    local node_addresses=$(kubectl get node -o jsonpath={.status.addresses} $node_name )
 
    for altname in $csr_altnames; do
        if [[ "$altname" =~ ^DNS:(.+)$ ]]; then
            local dns_altname="${BASH_REMATCH[1]}"
            echo $node_addresses | jq -c -r -e --arg v "$dns_altname"  '[.[] | select (.type=="Hostname")| .address] | index ($v)' > /dev/null
            check_result=$?
            if [[ "$check_result" != 0 ]]; then
                echo "Found DNS SubjAltName in CSR $csr_name that doesn't belong to Node $node_name: $altname"
            fi
        elif [[ "$altname" =~ ^IPAddress:(.+)$ ]]; then
            local ip_altname="${BASH_REMATCH[1]}"
            echo $node_addresses | jq -c -r -e --arg v "$ip_altname"  '[.[] | select (.type=="InternalIP")| .address] | index ($v)' >/dev/null
            check_result=$?
            if [[ "$check_result" != 0 ]]; then
                echo "Found IP SubjAltName in CSR $csr_name that doesn't belong to Node $node_name: $altname"
            fi
        else
            echo "Found SubjAltName in CSR $csr_name that is not IP or DNS: $altname"
            check_result=1
        fi
 
        if [[ "$check_result" != 0 ]]; then
            break
        fi
 
    done
 
    return $check_result
 
}
        
 
 
extract_node_name() {
    local csr_name="$1"
    local username
    
    username=$(kubectl get csr "$csr_name" -o jsonpath='{.spec.username}' 2>/dev/null)
    log_debug "username for $csr_name: $username" >&2
    if [[ -z "$username" ]]; then
        log_error "Could not extract username from CSR $csr_name"
        return 1
    fi
    
    # Username expected format: system:node:<NODE_NAME>
    if [[ "$username" =~ ^system:node:(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        log_error "Username '$username' does not match 'system:node:*' pattern"
        return 1
    fi
}
 
 
# Check if a given node exists in the cluster
node_exists() {
    local node_name="$1"
    
    if kubectl get node "$node_name" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
 
# Get node Ready status (prints "True", "False", or "Unknown")
get_node_status() {
    local node_name="$1"
    
    kubectl get node "$node_name" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown"
}
 
# Approve the CSR for the given node (with dry-run support)
approve_csr() {
    local csr_name="$1"
    local node_name="$2"
    local node_status="$3"
    local reason="Auto-approved: Node $node_name exists in cluster (status: $node_status)"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would approve CSR $csr_name for node $node_name (node status: $node_status)"
        return 0
    fi
    # Attempt to approve the CSR
    if kubectl certificate approve "$csr_name" >/dev/null 2>&1; then
        log_info "Approved CSR $csr_name for node $node_name (status: $node_status)"
        return 0
    else
        log_error "Failed to approve CSR $csr_name for node $node_name"
        return 1
    fi
}
 
 
# Process a single CSR
process_csr() {
    local csr_name="$1"
    local signer_name
    local node_name
    local node_status
    
    log_debug "Processing CSR: $csr_name"
    
    # Check if it's a kubelet-serving CSR
    signer_name=$(kubectl get csr "$csr_name" -o jsonpath='{.spec.signerName}' 2>/dev/null)
    
    if [[ "$signer_name" != "kubernetes.io/kubelet-serving" ]]; then
        log_debug "Skipping CSR $csr_name - not a kubelet-serving CSR (signer: $signer_name)"
        return 0
    fi
    
    # Extract node name
    if ! node_name=$(extract_node_name "$csr_name"); then
        log_warn "Skipping CSR $csr_name - could not extract valid node name from CSR subject"
        return 0
    fi
    
    log_debug "Extracted node name from CSR $csr_name: $node_name"
    
    # Check if node exists
    if ! node_exists "$node_name"; then
        log_warn "Skipping CSR $csr_name - node $node_name does not exist in cluster"
        return 0
    fi
 
    csr_groups=$(kubectl get csr "$csr_name" -o jsonpath='{.spec.groups}' 2>/dev/null)
 
    # Check if csr groups contains system:nodes
    if [[ "$csr_groups" =~ ^\[.*\"system:nodes\".*$ ]]; then
        log_info "CSR Groups $csr_groups contains system:nodes"
      else
        log_warn "Skipping CSR $csr_name - CSR Groups $csr_groups does not contain system:nodes"
        return 0
    fi
 
    csr_usages=$(kubectl get csr "$csr_name" -o jsonpath='{.spec.usages}' 2>/dev/null)
 
    # Remove allowed usages from csr_usages
    filtered_csr_usage=$(echo $csr_usages | sed -e 's/"digital signature"//g' -e 's/"key encipherment"//g' -e 's/,//g' )
 
    # Check if filteres csr usages ( the optional permitted onse are removed ) is equal to server auth
    if [[ "$filtered_csr_usage" != "[\"server auth\"]" ]]; then
        log_warn "CSR Usages $csr_usages contains forbidden usages"
        return 0
      else
        log_info "CSR Usages $csr_usages contains only allowed usages"   
    fi
 
    # Check if csr groups contains system:nodes
    if [[ "$csr_groups" =~ ^\[.*\"system:nodes\".*\]$ ]]; then
        log_info "CSR $csr_name contains group system:nodes"
      else
        log_warn "Skipping CSR $csr_name - system:nodes is not contained in csr groups"
        return 1
    fi
 
    echo "controllo altnames"
    if check_subj_altnames "$csr_name" "$node_name" ; then
        log_info "All subjectAltNames in $csr_name vare valid for Node $node_name"
    else
        return 1
    fi
    
    # Get node status
    node_status=$(get_node_status "$node_name")
    
    # Approve the CSR (we accept nodes in any status: Ready, NotReady, Unknown)
    if approve_csr "$csr_name" "$node_name" "$node_status"; then
        return 0
    else
        return 1
    fi
}
 
# Main processing function
process_pending_csrs() {
    local csrs
    local csr_count=0
    local approved_count=0
    local skipped_count=0
    local error_count=0
    
    log_info "Starting CSR processing run"
    
    # Get all pending CSR names (no approval condition in status)
    csrs=$(kubectl get csr -o json | jq -r '.items[] | select(.status.conditions == null) | .metadata.name' 2>/dev/null)
 
    log_info "Pending CSRs found: $csrs"
    
    if [[ -z "$csrs" ]]; then
        log_info "No pending CSRs found"
        return 0
    fi
    
    # Process each CSR
    while IFS= read -r csr_name; do
        [[ -z "$csr_name" ]] && continue
        
        csr_count=$(( csr_count + 1))
        
        if process_csr "$csr_name"; then
            # Check if it was approved
            if kubectl get csr "$csr_name" -o jsonpath='{.status.conditions[?(@.type=="Approved")].type}' 2>/dev/null | grep -q "Approved"; then
                approved_count=$(( approved_count + 1 ))
            else
                skipped_count=$(( skipped_count + 1 ))
            fi
        else
            error_count=$(( error_count + 1 ))
        fi
    done <<< "$csrs"
    
    log_info "CSR processing completed: total=$csr_count, approved=$approved_count, skipped=$skipped_count, errors=$error_count"
}
 
# Main execution
main() {
    # Parse command line arguments
    parse_args "$@"
    
    log_info "CSR Auto-Approver starting"
    log_debug "Configuration: LOG_LEVEL=$LOG_LEVEL, DRY_RUN=$DRY_RUN"
    
    # Check prerequisites
    check_prerequisites
    
    # Process pending CSRs
    process_pending_csrs
    
    log_info "CSR Auto-Approver completed"
}
 
# Execute main function
main "$@"