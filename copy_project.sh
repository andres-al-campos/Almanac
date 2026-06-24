#!/bin/bash

# This script copies the Project Almanac files to this directory
# Run with: bash copy_project.sh

echo "Copying Project Almanac files..."

# The files are located in Claude's outputs
# You'll need to manually download them from the Claude interface first
# Then run this script from the directory where you saved them

echo "Files should be downloaded from Claude to this location:"
echo "/Users/alejandro/Projects/Code/Almanac/"
echo ""
echo "Once downloaded, the structure should be:"
echo "Almanac/"
echo "├── Almanac/"
echo "│   ├── AlmanacApp.swift"
echo "│   ├── Models/TradingCalendar.swift"
echo "│   ├── Managers/NotificationManager.swift"
echo "│   └── Views/ContentView.swift"
echo "├── Almanac.xcodeproj/project.pbxproj"
echo "├── README.md"
echo "└── QUICKSTART.md"
