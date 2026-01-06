---
title: "Comprehensive CA Policy Audit Script"
date: "2026-01-04"
tags: ["PowerShell", "Entra ID", "Conditional Access", "Security"]
categories: ["Cloud"]
author: "Radu Bogdan"
description: "A comprehensive PowerShell script to audit all your Conditional Access policies in Entra ID"
thumbnail: "/images/conditional-access-policies.png"
draft: false
---

## Overview

![Conditional Access Overview](/images/ca-overview.png)

Here's a comprehensive script to audit all your Conditional Access policies. 

This script connects to Microsoft Graph, retrieves all CA policies, and provides detailed information about each one including user assignments, applications, conditions, and grant controls.

It also checks whether your break-glass account is properly excluded from each policy.

## The Script

```powershell
# Comprehensive CA Policy Audit Script
# Run this to get full details of all your policies

Connect-MgGraph -Scopes "Policy.Read.All", "User.Read.All"

Write-Host "`n=== CONDITIONAL ACCESS POLICY AUDIT ===" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n" -ForegroundColor Gray

# Get break-glass account ID for exclusion check
$breakGlassUPN = "breakglass@devworkplace.cloud"
$breakGlassUser = Get-MgUser -Filter "userPrincipalName eq '$breakGlassUPN'" -ErrorAction SilentlyContinue
$breakGlassId = if ($breakGlassUser) { $breakGlassUser.Id } else { "NOT FOUND" }

Write-Host "Break-Glass Account: $breakGlassUPN" -ForegroundColor Yellow
Write-Host "Break-Glass ID: $breakGlassId`n" -ForegroundColor Gray

# Get all CA policies
$policies = Get-MgIdentityConditionalAccessPolicy

foreach ($policy in $policies) {
    Write-Host "========================================" -ForegroundColor DarkGray
    Write-Host "POLICY: $($policy.DisplayName)" -ForegroundColor Green
    Write-Host "State: $($policy.State)" -ForegroundColor $(if ($policy.State -eq "enabled") {"Green"} else {"Yellow"})
    Write-Host "Created: $($policy.CreatedDateTime)"
    Write-Host "Modified: $($policy.ModifiedDateTime)"
    
    # Users
    Write-Host "`n--- USERS ---" -ForegroundColor Cyan
    Write-Host "Include Users: $($policy.Conditions.Users.IncludeUsers -join ', ')"
    Write-Host "Include Groups: $($policy.Conditions.Users.IncludeGroups -join ', ')"
    Write-Host "Include Roles: $($policy.Conditions.Users.IncludeRoles -join ', ')"
    Write-Host "Exclude Users: $($policy.Conditions.Users.ExcludeUsers -join ', ')"
    Write-Host "Exclude Groups: $($policy.Conditions.Users.ExcludeGroups -join ', ')"
    
    # Break-glass exclusion check
    $bgExcluded = $policy.Conditions.Users.ExcludeUsers -contains $breakGlassId
    Write-Host "Break-Glass Excluded: $bgExcluded" -ForegroundColor $(if ($bgExcluded) {"Green"} else {"Red"})
    
    # Applications
    Write-Host "`n--- APPLICATIONS ---" -ForegroundColor Cyan
    Write-Host "Include Apps: $($policy.Conditions.Applications.IncludeApplications -join ', ')"
    Write-Host "Exclude Apps: $($policy.Conditions.Applications.ExcludeApplications -join ', ')"
    
    # Conditions
    Write-Host "`n--- CONDITIONS ---" -ForegroundColor Cyan
    Write-Host "Platforms: $($policy.Conditions.Platforms.IncludePlatforms -join ', ')"
    Write-Host "Locations Include: $($policy.Conditions.Locations.IncludeLocations -join ', ')"
    Write-Host "Locations Exclude: $($policy.Conditions.Locations.ExcludeLocations -join ', ')"
    Write-Host "Client Apps: $($policy.Conditions.ClientAppTypes -join ', ')"
    Write-Host "Sign-in Risk: $($policy.Conditions.SignInRiskLevels -join ', ')"
    Write-Host "User Risk: $($policy.Conditions.UserRiskLevels -join ', ')"
    
    # Grant Controls
    Write-Host "`n--- GRANT CONTROLS ---" -ForegroundColor Cyan
    Write-Host "Operator: $($policy.GrantControls.Operator)"
    Write-Host "Built-in Controls: $($policy.GrantControls.BuiltInControls -join ', ')"
    
    if ($policy.GrantControls.AuthenticationStrength) {
        Write-Host "Authentication Strength: $($policy.GrantControls.AuthenticationStrength.DisplayName)" -ForegroundColor Magenta
    }
    
    if ($policy.GrantControls.TermsOfUse) {
        Write-Host "Terms of Use: $($policy.GrantControls.TermsOfUse -join ', ')"
    }
    
    # Session Controls
    Write-Host "`n--- SESSION CONTROLS ---" -ForegroundColor Cyan
    if ($policy.SessionControls) {
        Write-Host "Sign-in Frequency: $($policy.SessionControls.SignInFrequency.Value) $($policy.SessionControls.SignInFrequency.Type)"
        Write-Host "Persistent Browser: $($policy.SessionControls.PersistentBrowser.Mode)"
    } else {
        Write-Host "None configured"
    }
    
    Write-Host ""
}

# Summary
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total Policies: $($policies.Count)"
Write-Host "Enabled: $(($policies | Where-Object {$_.State -eq 'enabled'}).Count)"
Write-Host "Report-Only: $(($policies | Where-Object {$_.State -eq 'enabledForReportingButNotEnforced'}).Count)"
Write-Host "Disabled: $(($policies | Where-Object {$_.State -eq 'disabled'}).Count)"

# Break-glass exclusion summary
$missingExclusions = $policies | Where-Object { $_.Conditions.Users.ExcludeUsers -notcontains $breakGlassId }
if ($missingExclusions.Count -gt 0) {
    Write-Host "`nWARNING: Break-glass NOT excluded from:" -ForegroundColor Red
    $missingExclusions | ForEach-Object { Write-Host "  - $($_.DisplayName)" -ForegroundColor Red }
} else {
    Write-Host "`nBreak-glass excluded from all policies" -ForegroundColor Green
}
```

## Prerequisites

Before running this script, ensure you have:

- Microsoft Graph PowerShell SDK installed
- Appropriate permissions (Policy.Read.All, User.Read.All)
- Access to your Entra ID tenant

## What It Checks

For each Conditional Access policy, the script displays:

- Policy name, state, and timestamps
- User and group inclusions/exclusions
- Application scope
- Platform and location conditions
- Client app types and risk levels
- Grant controls (MFA, compliant device, etc.)
- Session controls (sign-in frequency, persistent browser)
- Break-glass account exclusion status
