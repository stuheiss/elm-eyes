
SOURCES = $(wildcard src/*.elm)
TARGET = build/index.html

.PHONY: all
all: $(TARGET)

$(TARGET): $(SOURCES)
	elm make --yes --output build/index.html src/Face.elm

.PHONY: clean
clean:
	rm -rf build elm-stuff
