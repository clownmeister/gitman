#!/bin/bash

# Install all packages listed in dependencies.txt
while IFS= read -r package || [[ -n "$package" ]]; do
  # Trim whitespace and skip empty or comment lines
  package=$(echo "$package" | xargs)
  [[ -z "$package" || "$package" =~ ^# ]] && continue

  # Install the package
  echo "Installing $package..."
  sudo apt install -y "$package"
done < dependencies.txt

echo "All dependencies installed."
