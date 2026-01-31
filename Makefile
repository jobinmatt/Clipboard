APP_NAME = ClipboardHistory
SOURCES = $(wildcard Sources/ClipboardHistory/*.swift)
SWIFTC_FLAGS = -target arm64-apple-macosx14.0 -framework Cocoa -framework SwiftUI -framework Carbon

all: build

build: $(SOURCES)
	swiftc $(SWIFTC_FLAGS) $(SOURCES) -o $(APP_NAME)

run: build
	./$(APP_NAME)

clean:
	rm -f $(APP_NAME)
	rm -rf $(APP_NAME).app

app: build
	mkdir -p $(APP_NAME).app/Contents/MacOS
	mkdir -p $(APP_NAME).app/Contents/Resources
	cp Info.plist $(APP_NAME).app/Contents/
	cp ClipboardHistory.icns $(APP_NAME).app/Contents/Resources/AppIcon.icns
	cp $(APP_NAME) $(APP_NAME).app/Contents/MacOS/
	chmod +x $(APP_NAME).app/Contents/MacOS/$(APP_NAME)
	@echo "App Bundle Created: $(APP_NAME).app"
