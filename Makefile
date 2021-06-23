# Makefile --------------------------------------------------------------------

TARGET = pidigits
 
#------------------------------------------------------------------------------

# Compiler flags
CFLAGS = -Wall -Werror -Wextra -Wpedantic -O3 -fomit-frame-pointer -march=native -pipe -std=c17
LDFLAGS = -lpthread -lgmp

# OS name identifier
OSNAME != uname -s

# Platform specific linker flags
ifeq ($(OSNAME),FreeBSD)
	LDFLAGS += -L/usr/local/lib -lstdthreads
endif

# Basic shell commands and utils
CC = cc
COPY = cp -v
ECHO = echo
FIND = find
MKDIR = mkdir -p
RM = rm -f
RMDIR = rm -rf
SORT = sort

# Directory structure
OBJDIR = obj
SRCDIR = src

# Artifacts
MAKEFILE = Makefile
HEADERS != $(FIND) $(SRCDIR) -type f -name "*.h" | $(SORT)
SOURCES != $(FIND) $(SRCDIR) -type f -name "*.c" | $(SORT)
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

#------------------------------------------------------------------------------

.PHONY: default
default: build

.PHONY: clean
clean:
	@$(ECHO) "*** Clean Started ***"
	$(RM) *.out
	$(RM) $(TARGET).core
	$(RM) $(TARGET).gmon
	$(RM) $(TARGET)
	$(RMDIR) $(OBJDIR)
	@$(ECHO) "*** Clean Finished ***"

.PHONY: build
build: $(TARGET)
	@$(ECHO) "*** Build Finished ***"

# Rule to build the target with profiling enabled
.PHONY: profile
profile: CFLAGS += -pg
profile: LDFLAGS += -pg
profile: build
	@$(ECHO) "*** Profile Build Finshed ***"

# Rule to build the target with profiling enabled
.PHONY: release
release: CFLAGS += -DNDEBUG
release: build
	@$(ECHO) "*** Release Build Finshed ***"

.PHONY: run
run: build
	@$(ECHO) "*** Running: $(TARGET) ***"
	./$(TARGET)

.PHONY: help
help:
	@$(ECHO) "*** Make Targets ***"
	@$(ECHO) "clean:    Cleanup all generated object files"
	@$(ECHO) "build:    Compile and link TARGET"
	@$(ECHO) "profile:  Compile and link TARGET with profiling"
	@$(ECHO) "release:  Compile and link TARGET without debug"
	@$(ECHO) "run:      Execute the TARGET"
	@$(ECHO) "vars      Dump out Makefile variables for debugging"

# Rule for dumping makefile variables for debugging
.PHONY: vars
vars:
	@$(ECHO) "*** Make Variables ***"
	@$(ECHO) TARGET: $(TARGET)
	@$(ECHO) CFLAGS: $(CFLAGS)
	@$(ECHO) LDFLAGS: $(LDFLAGS)
	@$(ECHO) SRCDIR: $(SRCDIR)
	@$(ECHO) OBJDIR: $(OBJDIR)
	@$(ECHO) HEADERS: $(HEADERS)
	@$(ECHO) SOURCES: $(SOURCES)
	@$(ECHO) OBJECTS: $(OBJECTS)

#------------------------------------------------------------------------------

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $(TARGET)

# Rule to compile each object file (depends on sources, headers, this Makefile)
$(OBJDIR)/%.o: $(SRCDIR)/%.c $(HEADERS) $(MAKEFILE)
	@$(MKDIR) $(@D)
	$(CC) $(CFLAGS)  -c $< -o $@ 

#------------------------------------------------------------------------------
