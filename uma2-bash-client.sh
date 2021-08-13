#!/bin/bash

function get_uma2_configuration {
    curl -sS $UMA2_ENDPOINT | jq $FIELD -r
}

function get_authorization_resource {
    curl -sS --request POST --url $TOKEN_ENDPOINT \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      --data "grant_type=urn:ietf:params:oauth:grant-type:uma-ticket" \
      --data "audience=$AUDIENCE" \
      --data "permission=$RESOURCE#$SCOPE" \
      | jq $FIELD -r
}

function get_all_authorizations {
    curl -sS --request POST --url $TOKEN_ENDPOINT \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      --data "grant_type=urn:ietf:params:oauth:grant-type:uma-ticket" \
      --data "audience=$AUDIENCE" \
      | jq $FIELD -r
}

function push_claims {
    curl -sS --request POST --url $TOKEN_ENDPOINT \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      --data "grant_type=urn:ietf:params:oauth:grant-type:uma-ticket" \
      --data "claim_token=$CLAIM" \
      --data "claim_token_format=urn:ietf:params:oauth:token-type:jwt" \
      --data "client_id=$CLIENT_ID" \
      --data "client_secret=$CLIENT_SECRET" \
      --data "audience=$AUDIENCE"\
      | jq $FIELD -r
}

function rpt_token_request_no_persist {
    curl -sS --request POST --url $TOKEN_ENDPOINT \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      --data "grant_type=urn:ietf:params:oauth:grant-type:uma-ticket" \
      --data "ticket=$TICKET" \
      | jq $FIELD -r
}

function rpt_token_request_persist {
    curl -Ss --request POST --url $TOKEN_ENDPOINT \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      --data "grant_type=urn:ietf:params:oauth:grant-type:uma-ticket" \
      --data "ticket=$TICKET" \
      --data "submit_request=true" \
      | jq $FIELD -r
}

function list_resources {
    curl -sS --request GET --url $RESOURCE_ENDPOINT \
      --header "Authorization: Bearer $ACCESS_TOKEN"\
      | jq $FIELD -r
}

function get_resource {
    curl -sS --request GET --url $RESOURCE_ENDPOINT/$RESOURCE \
    --header "Authorization: Bearer $ACCESS_TOKEN"\
      | jq $FIELD -r
}

function create_resource {
    curl -sS --request POST --url $RESOURCE_ENDPOINT \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --header 'Content-Type: application/json' \
      --data "{ \"name\": \"$RESOURCE_NAME\", \
       \"owner\": \"$RESOURCE_OWNER\",\
       \"type\": \"$RESOURCE_TYPE\",\
       \"resource_scopes\": $RESOURCE_SCOPES,
       \"ownerManagedAccess\": true }" \
      | jq $FIELD -r
}

function update_resource {
    curl -sS --request PUT --url $RESOURCE_ENDPOINT/$RESOURCE \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --header 'Content-Type: application/json' \
      --data "{ \"_id\": \"$RESSOURCE\", 
       \"name\": \"$RESOURCE_NAME\",\
       \"owner\": \"$RESOURCE_OWNER\",\
       \"type\": \"$RESOURCE_TYPE\",\
       \"resource_scopes\": $RESOURCE_SCOPES,
       \"ownerManagedAccess\": true }" \
      | jq $FIELD -r
}

function delete_resource {
    curl -sS --request DELETE --url $RESOURCE_ENDPOINT/$RESOURCE \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --header 'Content-Type: application/json' \
      | jq $FIELD -r
}

function create_permission_ticket {
    curl -sS --request POST --url $PERMISSION_ENDPOINT \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --header 'Content-Type: application/json' \
      --data "[{
          \"resource_id\": \"$RESOURCE\",\
          \"resource_scopes\": $RESOURCE_SCOPES
        }]" \
      | jq $FIELD -r
}

function get_permission_tickets {
    curl -sS --request GET --url $PERMISSION_ENDPOINT/ticket \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      | jq $FIELD -r
}

function delete_permission_ticket {
    curl -sS --request DELETE --url $PERMISSION_ENDPOINT/ticket/$TICKET \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      | jq $FIELD -r
}

function share_access {
    curl -sS --request POST --url $PERMISSION_ENDPOINT/ticket \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      --header 'Content-Type: application/json' \
      --data "{
          \"resource\": \"$RESOURCE\", \"requester\": \"$REQUESTER\", \"granted\": $GRANTED,
          \"scopeName\": \"$SCOPE\"
        }" \
      | jq $FIELD -r
}

function revoke_access {
    curl -sS --request POST $PERMISSION_ENDPOINT/ticket \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      --header 'Content-Type: application/json' \
      --data "{
          \"resource\": \"$RESOURCE\", \"requester\": \"$REQUESTER\", \"granted\": false,
          \"scopeName\": \"$SCOPE\"
        }" \
      | jq $FIELD -r
}

function list_permissions {
    curl -sS --request GET --url $PERMISSION_ENDPOINT/ticket \
      --header 'Authorization: Bearer '$ACCESS_TOKEN \
      | jq $FIELD -r
}

function show_help {

echo "PLEASE-OPEN.IT UMA2.0 BASH CLIENT"
echo "SYNOPSIS"
echo ""
echo "uma2-client.sh --operation OP --uma2-configuration-endpoint [--resource-endpoint --token-endpoint --permission-endpoint] --access-token --ticket --resource-name --resource-owner --resource-type --resource-scopes --resource --requester --audience --client-id --client-secret --scope --claim --granted --field "



echo "DESCRIPTION"
echo ""
echo "This script is a wrapper over uma2.0"

echo "OPTIONS"
echo "  --operation in : "
echo "  CONFIGURATION"
echo "    get_uma2_configuration"
echo "    get_authorization_resource"
echo "    get_all_authorizations"
echo "    push_claims"
echo "    request_party_token_no_persistence"
echo "    request_party_token_persistence"
echo "  RESOURCES MANAGEMENT"
echo "    list_resources"
echo "    get_resource"
echo "    create_resource"
echo "    update_resource"
echo "    delete_resource"
echo "  PERMISSIONS"
echo "    create_permission_ticket"
echo "    get_permission_tickets"
echo "    delete_permission_ticket"
echo "    share_access"
echo "    revoke_access"
echo "    list_permissions"
echo ""
echo " --field : filter for JQ"
echo ""
echo "More : "
}

PARAMS=""
while (( "$#" )); do
  case "$1" in
    --help)
      show_help
      shift
      ;;
    --operation)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OPERATION=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --uma2-configuration-endpoint)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        UMA2_ENDPOINT=$2
        shift 2
      fi
      ;;
    --client-id)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        CLIENT_ID=$2
        shift 2
      fi
      ;;
    --client-secret)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        CLIENT_SECRET=$2
        shift 2
      fi
      ;;
    --audience)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        AUDIENCE=$2
        shift 2
      fi
      ;;
    --resource-endpoint)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        RESOURCE_ENDPOINT=$2
        shift 2
      fi
      ;;
    --token-endpoint)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        TOKEN_ENDPOINT=$2
        shift 2
      fi
      ;;
    --permission-endpoint)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PERMISSION_ENDPOINT=$2
        shift 2
      fi
      ;;
    --access-token)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ACCESS_TOKEN=$2
        shift 2
      fi
      ;;
    --ticket)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        TICKET=$2
        shift 2
      fi
      ;;
    --resource-name)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        RESOURCE_NAME=$2
        shift 2
      fi
      ;;
    --resource-type)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        RESOURCE_TYPE=$2
        shift 2
      fi
      ;;
    --resource-scopes)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        RESOURCE_SCOPES=$2
        shift 2
      fi
      ;;
    --resource-owner)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        RESOURCE_OWNER=$2
        shift 2
      fi
      ;;
    --resource)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        RESOURCE=$2
        shift 2
      fi
      ;;
    --requester)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        REQUESTER=$2
        shift 2
      fi
      ;;
    --granted)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        GRANTED=$2
        shift 2
      fi
      ;;
    --scope)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        SCOPE=$2
        shift 2
      fi
      ;;
    --claim)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        CLAIM=$2
        shift 2
      fi
      ;;
    --field)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        FIELD=$2
        shift 2
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done


case "$OPERATION" in
  get_uma2_configuration)
    if [ -z "$UMA2_ENDPOINT" ]; then
      echo "Error: --uma2-configuration-endpoint is missing" >&2
      exit 1
    fi
    get_uma2_configuration
    ;;
  get_authorization_resource)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$TOKEN_ENDPOINT" ]; then
      echo "Error: --token-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$AUDIENCE" ]; then
      echo "Error: --audience is missing" >&2
      exit 1
    fi
    if [ -z "$SCOPE" ]; then
      echo "Error: --scope is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE" ]; then
      echo "Error: --resource is missing" >&2
      exit 1
    fi
    if [ -z "$TOKEN_ENDPOINT" ]; then
      TOKEN_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .token_endpoint -r)
    fi
    get_authorization_resource
    ;;
  get_all_authorizations)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$TOKEN_ENDPOINT" ]; then
      echo "Error: --token-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$AUDIENCE" ]; then
      echo "Error: --audience is missing" >&2
      exit 1
    fi
    if [ -z "$TOKEN_ENDPOINT" ]; then
      TOKEN_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .token_endpoint -r)
    fi
    get_all_authorizations
    ;;
  push_claims)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$TOKEN_ENDPOINT" ]; then
      echo "Error: --token-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$CLIENT_ID" ]; then
      echo "Error: --client-id is missing" >&2
      exit 1
    fi
    if [ -z "$CLIENT_SECRET" ]; then
      echo "Error: --client-secret is missing" >&2
      exit 1
    fi
    if [ -z "$AUDIENCE" ]; then
      echo "Error: --audience is missing" >&2
      exit 1
    fi
    if [ -z "$CLAIM" ]; then
      echo "Error: --claim is missing" >&2
      exit 1
    fi
    if [ -z "$TOKEN_ENDPOINT" ]; then
      TOKEN_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .token_endpoint -r)
    fi
    push_claims
    ;;
  request_party_token_no_persistence)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$TOKEN_ENDPOINT" ]; then
      echo "Error: --token-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$TICKET" ]; then
      echo "Error: --ticket is missing" >&2
      exit 1
    fi
    if [ -z "$TOKEN_ENDPOINT" ]; then
      TOKEN_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .token_endpoint -r)
    fi
    rpt_token_request_no_persist
    ;;
  request_party_token_persistence)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$TOKEN_ENDPOINT" ]; then
      echo "Error: --token-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$TICKET" ]; then
      echo "Error: --ticket is missing" >&2
      exit 1
    fi
    if [ -z "$TOKEN_ENDPOINT" ]; then
      TOKEN_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .token_endpoint -r)
    fi
    rpt_token_request_persist
    ;;
  list_resources)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$RESOURCE_ENDPOINT" ]; then
      echo "Error: --resource-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_ENDPOINT" ]; then
      RESOURCE_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .resource_registration_endpoint -r)
    fi
    list_resources
    ;;
  get_resource)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$PERMISSION_ENDPOINT" ]; then
      echo "Error: --permission-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE" ]; then
      echo "Error: --resource is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_ENDPOINT" ]; then
      RESOURCE_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .resource_registration_endpoint -r)
    fi
    get_resource
    ;;
  create_resource)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$RESOURCE_ENDPOINT" ]; then
      echo "Error: --resource-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_NAME" ]; then
      echo "Error: --resource-name is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_OWNER" ]; then
      echo "Error: --resource-owner is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_TYPE" ]; then
      echo "Error: --resource-type is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_SCOPES" ]; then
      echo "Error: --resource-scopes is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_ENDPOINT" ]; then
      RESOURCE_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .resource_registration_endpoint -r)
    fi
    create_resource
    ;;
  update_resource)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$RESOURCE_ENDPOINT" ]; then
      echo "Error: --resource-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE" ]; then
      echo "Error: --resource is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_NAME" ]; then
      echo "Error: --resource-name is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_OWNER" ]; then
      echo "Error: --resource-owner is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_TYPE" ]; then
      echo "Error: --resource-type is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_SCOPES" ]; then
      echo "Error: --resource-scopes is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_ENDPOINT" ]; then
      RESOURCE_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .resource_registration_endpoint -r)
    fi
    update_resource
    ;;
  delete_resource)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$RESOURCE_ENDPOINT" ]; then
      echo "Error: --resource-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE" ]; then
      echo "Error: --resource is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_ENDPOINT" ]; then
      RESOURCE_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .resource_registration_endpoint -r)
    fi
    delete_resource
    ;;
  create_permission_ticket)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$PERMISSION_ENDPOINT" ]; then
      echo "Error: --permission-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE" ]; then
      echo "Error: --resource is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE_SCOPES" ]; then
      echo "Error: --resource-scopes is missing" >&2
      exit 1
    fi
    if [ -z "$PERMISSION_ENDPOINT" ]; then
      PERMISSION_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .permission_endpoint -r)
    fi
    create_permission_ticket
    ;;
  get_permission_tickets)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$PERMISSION_ENDPOINT" ]; then
      echo "Error: --permission-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$PERMISSION_ENDPOINT" ]; then
      PERMISSION_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .permission_endpoint -r)
    fi
    get_permission_tickets
    ;;
  delete_permission_ticket)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$PERMISSION_ENDPOINT" ]; then
      echo "Error: --permission-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE" ]; then
      echo "Error: --resource is missing" >&2
      exit 1
    fi
    if [ -z "$PERMISSION_ENDPOINT" ]; then
      PERMISSION_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .permission_endpoint -r)
    fi
    delete_permission_ticket
    ;;
  share_access)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$PERMISSION_ENDPOINT" ]; then
      echo "Error: --permission-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE" ]; then
      echo "Error: --resource is missing" >&2
      exit 1
    fi
    if [ -z "$REQUESTER" ]; then
      echo "Error: --requester is missing" >&2
      exit 1
    fi
    if [ -z "$GRANTED" ]; then
      echo "Error: --granted is missing" >&2
      exit 1
    fi
    if [ -z "$SCOPE" ]; then
      echo "Error: --scope is missing" >&2
      exit 1
    fi
    if [ -z "$PERMISSION_ENDPOINT" ]; then
      PERMISSION_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .permission_endpoint -r)
    fi
    share_access
    ;;
  revoke_access)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$PERMISSION_ENDPOINT" ]; then
      echo "Error: --permission-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$RESOURCE" ]; then
      echo "Error: --resource is missing" >&2
      exit 1
    fi
    if [ -z "$REQUESTER" ]; then
      echo "Error: --requester is missing" >&2
      exit 1
    fi
    if [ -z "$SCOPE" ]; then
      echo "Error: --scope is missing" >&2
      exit 1
    fi
    if [ -z "$PERMISSION_ENDPOINT" ]; then
      PERMISSION_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .permission_endpoint -r)
    fi
    revoke_access
    ;;
  list_permissions)
    if [ -z "$UMA2_ENDPOINT" ] && [ -z "$PERMISSION_ENDPOINT" ]; then
      echo "Error: --permission-endpoint is missing, you can also use --uma2-configuration-endpoint" >&2
      exit 1
    fi
    if [ -z "$ACCESS_TOKEN" ]; then
      echo "Error: --access-token is missing" >&2
      exit 1
    fi
    if [ -z "$PERMISSION_ENDPOINT" ]; then
      PERMISSION_ENDPOINT=$(curl -sS $UMA2_ENDPOINT | jq .permission_endpoint -r)
    fi
    list_permissions
    ;;
  *)
    echo "unsupported operation"
    exit 1
    ;;
  
esac

