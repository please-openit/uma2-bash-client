# please-open.it bash UMA 2.0 wrapper

## Purpose
[please-open.it](https://please-open.it) specializes in authentication and web security, and provides Keycloak as a service.

This bash script is an uma 2.0 wrapper. You can make any authorization, tickets, and resources request from command line with the right arguments.

Supported operations are : 
- get_uma2_configuration
- get_authorization_resource
- get_all_authorizations
- get_ticket
- push_claims
- request_party_token_no_persistence
- request_party_token_persistence
- list_resources
- get_resource
- create_resource
- update_resource
- delete_resource
- create_permission_ticket
- delete_permission_ticket
- approve_access
- revoke_access
- list_permissions

Use it as a guide for UMA 2.0 discovery or in any testing/integration process. Script is totally stateless, save the output of a command in variables to reuse tokens.

## Disclaimer

This implementation has not all operations defined in UMA 2.0. Some operations (like resources management) are specific to Keycloak implementation.

You can test it with a [please-open.it](https://please-open.it) realm, all features are enabled.

See https://blog.please-open.it/uma for a complete tutorial with examples from this script.

## Install

You need curl and jq installed.

## External documentation

https://en.wikipedia.org/wiki/User-Managed_Access

https://www.keycloak.org/docs/latest/authorization_services/#_service_overview

https://docs.kantarainitiative.org/uma/rec-uma-core.html

https://kantarainitiative.org/confluence/display/uma/UMA+Implementations

