# Makefile Deployment Guide

This makefile provides automated deployment workflows for the Commercial Marketplace SaaS Accelerator applications to Azure Web Apps.

## Overview

The makefile supports deploying two applications:

- **CustomerSite**: The customer-facing portal
- **AdminSite**: The administrative portal

Each deployment follows a standard pipeline: clean → build → zip → push → restart.

## Prerequisites

Before using this makefile, ensure you have the following installed and configured:

### Required Tools

1. **make** - GNU Make utility
2. **.NET SDK** - For building and publishing the applications
3. **Azure CLI** - For deploying to Azure Web Apps
4. **zip** - For creating deployment packages

### Azure Authentication

You must be authenticated with Azure CLI:

```bash
az login
az account set --subscription <your-subscription-id>
```

Verify your authentication:

```bash
az account show
```

## Configuration

Before deploying, update the configuration variables at the top of the makefile to match your Azure environment:

### CustomerSite Configuration

```makefile
RESOURCE_GROUP = rg-ance-dev-eus2-app-s1-77    # Your Azure Resource Group
APP_NAME = app-ance-dev-eus2-portal-s1-77      # Your Azure Web App name
PROJECT_PATH = ./src/CustomerSite/CustomerSite.csproj
PUBLISH_DIR = ./Publish/CustomerSite
ZIP_PATH = ./Publish/CustomerSite.zip
RUNTIME = win-x86                               # Target runtime
CONFIGURATION = Release                         # Build configuration
```

### AdminSite Configuration

```makefile
ADMIN_RESOURCE_GROUP = $(RESOURCE_GROUP)       # Resource Group (often same as CustomerSite)
ADMIN_APP_NAME = app-ance-dev-eus2-admin-s1-77 # Admin Web App name
ADMIN_PROJECT_PATH = ./src/AdminSite/AdminSite.csproj
ADMIN_PUBLISH_DIR = ./Publish/AdminSite
ADMIN_ZIP_PATH = ./Publish/AdminSite.zip
ADMIN_RUNTIME = win-x86
ADMIN_CONFIGURATION = Release
```

## Usage

### Deploy CustomerSite

To deploy the CustomerSite application:

```bash
make deploy-customer-site
```

This command executes the following steps:

1. **clean** - Removes old build artifacts from `./Publish/CustomerSite`
2. **build** - Publishes the .NET application for the specified runtime
3. **zip** - Creates a deployment package at `./Publish/CustomerSite.zip`
4. **push** - Deploys the package to Azure Web App
5. **restart** - Restarts the Azure Web App to apply changes

### Deploy AdminSite

To deploy the AdminSite application:

```bash
make deploy-admin-site
```

This command executes the following steps:

1. **admin-clean** - Removes old AdminSite build artifacts
2. **admin-build** - Publishes the AdminSite .NET application
3. **admin-zip** - Creates the AdminSite deployment package
4. **admin-push** - Deploys to the Admin Azure Web App
5. **admin-restart** - Restarts the Admin Azure Web App

### Individual Targets

You can also run individual steps if needed:

#### CustomerSite Individual Steps

```bash
make clean          # Clean old CustomerSite artifacts
make build          # Build CustomerSite only
make zip            # Create CustomerSite deployment package
make push           # Deploy CustomerSite to Azure
make restart        # Restart CustomerSite Azure Web App
```

#### AdminSite Individual Steps

```bash
make admin-clean    # Clean old AdminSite artifacts
make admin-build    # Build AdminSite only
make admin-zip      # Create AdminSite deployment package
make admin-push     # Deploy AdminSite to Azure
make admin-restart  # Restart AdminSite Azure Web App
```

## Deployment Pipeline Details

### Build Process

The build step uses `dotnet publish` with the following options:

- **Configuration**: Release (optimized build)
- **Runtime**: win-x86 (Windows 32-bit)
- **Self-contained**: false (requires .NET runtime on target)

The build validates that `web.config` is present in the output, which is required for IIS hosting on Azure Web Apps.

### Deployment Method

Deployments use the Azure CLI `az webapp deploy` command with zip deployment, which:

- Uploads the entire application package
- Automatically extracts files to the web app
- Maintains proper permissions and structure

### Post-Deployment

After deployment, the web app is restarted to ensure all changes are applied and the application starts cleanly.

## Troubleshooting

### Common Issues

#### 1. Missing web.config

**Error**: `❌ Missing web.config — check your project/runtime!`

**Solution**:

- Ensure your .csproj file is configured for IIS hosting
- Verify the runtime matches your Azure Web App configuration
- Check that the project includes web.config generation settings

#### 2. Azure CLI Authentication Failed

**Error**: Authentication errors during push or restart

**Solution**:

```bash
az login
az account set --subscription <your-subscription-id>
```

#### 3. Resource Not Found

**Error**: Resource group or web app not found

**Solution**:

- Verify `RESOURCE_GROUP` and `APP_NAME` variables match your Azure resources
- Check that the resources exist: `az webapp show -g <resource-group> -n <app-name>`

#### 4. Permission Denied

**Error**: Insufficient permissions to deploy

**Solution**:

- Ensure your Azure account has Contributor or Website Contributor role on the Web App
- Check role assignments: `az role assignment list --assignee <your-email>`

#### 5. Build Failures

**Error**: `dotnet publish` fails

**Solution**:

- Ensure .NET SDK is installed: `dotnet --version`
- Restore packages: `dotnet restore <project-path>`
- Check for compilation errors in the project

### Viewing Deployment Logs

To view deployment logs in Azure:

```bash
az webapp log tail --resource-group <resource-group> --name <app-name>
```

To download logs:

```bash
az webapp log download --resource-group <resource-group> --name <app-name>
```

## Best Practices

1. **Test in Development First**: Always test deployments in a development environment before deploying to production
2. **Backup Configuration**: Backup your Azure Web App settings before deployment
3. **Version Control**: Commit the makefile configuration changes to track environment-specific settings
4. **Environment Variables**: Consider creating separate makefiles or using environment variables for different environments (dev, staging, prod)
5. **Deployment Slots**: For production, consider using Azure deployment slots for blue-green deployments

## Multi-Environment Setup

For managing multiple environments, you can create environment-specific makefiles:

```bash
# Development
make -f makefile.dev deploy-customer-site

# Staging
make -f makefile.staging deploy-customer-site

# Production
make -f makefile.prod deploy-customer-site
```

Or use environment variables:

```bash
export RESOURCE_GROUP=rg-prod-001
export APP_NAME=app-prod-portal-001
make deploy-customer-site
```

## Support

For issues related to:

- **Azure CLI**: https://docs.microsoft.com/cli/azure/
- **.NET Publishing**: https://docs.microsoft.com/dotnet/core/tools/dotnet-publish
- **Azure Web Apps**: https://docs.microsoft.com/azure/app-service/

## License

This makefile is part of the Commercial Marketplace SaaS Accelerator project.
