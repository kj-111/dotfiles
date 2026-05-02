# IntelliJ IDEA setup

## Editor

* Editor font: 19
* Theme: One Dark
* Plugin: IdeaVim
* IdeaVim plugin: `vim-highlightedyank`
* Inline completion: download model
* Yank highlight: 150ms
* Disable author inline hint: `Settings -> Editor -> Inlay Hints` en zet de author/code vision hint uit
* Disable Git gutter colors: `Settings -> Version Control -> Confirmation -> Highlight modified lines in gutter` uitzetten
* Disable typo detection: `Option+Enter -> Disable inspection`
* Relative line numbers: `Settings -> Editor -> General -> Appearance -> Show line numbers -> Hybrid`
* Actions on Save: `Settings -> Tools -> Actions on Save -> Reformat code` en `Optimize imports` aanzetten
* Reload IdeaVim config: `:source ~/.config/ideavim/ideavimrc`
* Reload na edit in ideavimrc: `Ctrl+Shift+O`

## Java

* Install Temurin 21: `brew install --cask temurin@21`
* Check installed JDKs: `/usr/libexec/java_home -V`
* `~/.zshrc`: `alias java21='export JAVA_HOME=$(/usr/libexec/java_home -v 21)'`
* Shell reload: `exec zsh`
* Project-specific Gradle JDK: zet in `gradle.properties` `org.gradle.java.home=/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home`
