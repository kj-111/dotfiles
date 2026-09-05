CC ?= cc
CPPFLAGS ?=
CFLAGS ?= -std=c23 -Wall -Wextra -Wpedantic -g -fsanitize=address,undefined
LDFLAGS ?=
LDLIBS ?=

PROJECT := __PROJECT_NAME__
TARGET := build/$(PROJECT)
SOURCES := $(wildcard src/*.c)
OBJECTS := $(patsubst src/%.c,build/%.o,$(SOURCES))
DEPENDENCIES := $(OBJECTS:.o=.d)

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

build/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

run: $(TARGET)
	./$(TARGET) $(ARGS)

clean:
	$(RM) -r build

-include $(DEPENDENCIES)
