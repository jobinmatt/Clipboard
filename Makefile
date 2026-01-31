APP_NAME = ClipboardHistory

all: build

build:
	swift build -c release

run:
	swift run

clean:
	rm -rf .build
	rm -rf $(APP_NAME).app

app: build
	mkdir -p $(APP_NAME).app/Contents/MacOS
	mkdir -p $(APP_NAME).app/Contents/Resources
	cp Info.plist $(APP_NAME).app/Contents/
	cp ClipboardHistory.icns $(APP_NAME).app/Contents/Resources/AppIcon.icns
	cp .build/release/$(APP_NAME) $(APP_NAME).app/Contents/MacOS/
	chmod +x $(APP_NAME).app/Contents/MacOS/$(APP_NAME)
	codesign --force --deep --sign - $(APP_NAME).app
	@echo "App Bundle Created and Signed: $(APP_NAME).app"
