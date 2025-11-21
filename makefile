# ===============================
# SaaS Accelerator - CustomerSite Deployment
# ===============================

RESOURCE_GROUP = rg-ance-dev-eus2-app-s1-77
APP_NAME = app-ance-dev-eus2-portal-s1-77
PROJECT_PATH = ./src/CustomerSite/CustomerSite.csproj
PUBLISH_DIR = ./Publish/CustomerSite
ZIP_PATH = ./Publish/CustomerSite.zip
RUNTIME = win-x86
CONFIGURATION = Release

ADMIN_RESOURCE_GROUP = $(RESOURCE_GROUP)
ADMIN_APP_NAME = app-ance-dev-eus2-admin-s1-77
ADMIN_PROJECT_PATH = ./src/AdminSite/AdminSite.csproj
ADMIN_PUBLISH_DIR = ./Publish/AdminSite
ADMIN_ZIP_PATH = ./Publish/AdminSite.zip
ADMIN_RUNTIME = win-x86
ADMIN_CONFIGURATION = Release


# Default target
deploy-customer-site: clean build zip push restart
	@echo "✅ CustomerSite Deployment completed successfully!"

clean:
	@echo "🧹 Cleaning old build artifacts..."
	@rm -rf $(PUBLISH_DIR) $(ZIP_PATH)

build:
	@echo "⚙️  Publishing CustomerSite for runtime $(RUNTIME)..."
	@dotnet publish $(PROJECT_PATH) -c $(CONFIGURATION) -o $(PUBLISH_DIR) --runtime $(RUNTIME) --self-contained false
	@ls $(PUBLISH_DIR) | grep web.config >/dev/null || (echo "❌ Missing web.config — check your project/runtime!" && exit 1)

zip:
	@echo "📦 Creating deployment package..."
	@cd $(PUBLISH_DIR) && zip -r ../CustomerSite.zip ./* -q
	@echo "✅ Package created at $(ZIP_PATH)"

push:
	@echo "🚀 Deploying to Azure Web App: $(APP_NAME)"
	@az webapp deploy \
		--resource-group $(RESOURCE_GROUP) \
		--name $(APP_NAME) \
		--src-path "$(ZIP_PATH)" \
		--type zip
	@echo "✅ Deployment pushed to Azure."

restart:
	@echo "🔄 Restarting Azure Web App..."
	@az webapp restart --resource-group $(RESOURCE_GROUP) --name $(APP_NAME)
	@echo "✅ App restarted successfully."

# ===============================
# SaaS Accelerator - AdminSite Deployment
# ===============================


deploy-admin-site: admin-clean admin-build admin-zip admin-push admin-restart
	@echo "✅ AdminSite Deployment completed successfully!"

admin-clean:
	@echo "🧹 Cleaning old AdminSite build artifacts..."
	@rm -rf $(ADMIN_PUBLISH_DIR) $(ADMIN_ZIP_PATH)

admin-build:
	@echo "⚙️  Publishing AdminSite for runtime $(ADMIN_RUNTIME)..."
	@dotnet publish $(ADMIN_PROJECT_PATH) -c $(ADMIN_CONFIGURATION) -o $(ADMIN_PUBLISH_DIR) --runtime $(ADMIN_RUNTIME) --self-contained false
	@ls $(ADMIN_PUBLISH_DIR) | grep web.config >/dev/null || (echo "❌ Missing web.config — check your project/runtime!" && exit 1)

admin-zip:
	@echo "📦 Creating AdminSite deployment package..."
	@cd $(ADMIN_PUBLISH_DIR) && zip -r ../AdminSite.zip ./* -q
	@echo "✅ Package created at $(ADMIN_ZIP_PATH)"

admin-push:
	@echo "🚀 Deploying AdminSite to Azure Web App: $(ADMIN_APP_NAME)"
	@az webapp deploy \
		--resource-group $(ADMIN_RESOURCE_GROUP) \
		--name $(ADMIN_APP_NAME) \
		--src-path "$(ADMIN_ZIP_PATH)" \
		--type zip
	@echo "✅ AdminSite Deployment pushed to Azure."

admin-restart:
	@echo "🔄 Restarting AdminSite Azure Web App..."
	@az webapp restart --resource-group $(ADMIN_RESOURCE_GROUP) --name $(ADMIN_APP_NAME)
	@echo "✅ AdminSite restarted successfully."

