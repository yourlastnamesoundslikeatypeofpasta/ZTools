# SolarWinds Service Desk Module

PowerShell cmdlets for interacting with the SolarWinds Service Desk REST API. The module provides simple wrappers around common endpoints so other modules can create and update tickets.

- API General Concepts: <https://apidoc.samanage.com/#section/General-Concepts>
- Full OpenAPI Schema: <https://apidoc.samanage.com/redoc/schema/resolved_schema.json>

Run `Set-SDConfig` once to store your base URL and API token in the SecretStore vault provided by PowerShell SecretManagement. Subsequent calls to `New-SDSession` will automatically read these values if no parameters are supplied.
All cmdlets return `[ZtEntity]` objects so they can be piped into other ZTools modules.
