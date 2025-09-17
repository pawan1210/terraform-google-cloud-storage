#!/bin/bash

PROJECT_IDS=(
  "component-prj-1033671763624"
  "component-prj-466042986942"
  "component-prj-591401743079"
  "component-prj-902573739346"
  "component-prj-684228394359"
  "component-prj-659197121383"
  "component-prj-1011530780658"
  "component-prj-174294635750"
  "component-prj-527221582138"
  "component-prj-1054699654560"
)

for project in "${PROJECT_IDS[@]}"; do
  echo "Processing project: $project"
  
  instance_ids=$(gcloud bigtable instances list --project="$project" --format="value(name.split('/').pop())")
  
  if [ -z "$instance_ids" ]; then
    echo "  No Bigtable instances found in project $project"
    continue
  fi
  
  for instance in $instance_ids; do
    echo "  Processing instance: $instance"
    
    table_ids=$(gcloud bigtable instances tables list --instances="$instance" --project="$project" --format="value(name.split('/').pop())")
    
    if [ -n "$table_ids" ]; then
      for table in $table_ids; do
        echo "    Disabling deletion protection for table: $table"
        gcloud bigtable instances tables update "$table" --instance="$instance" --project="$project" --no-deletion-protection
      done
    else
      echo "    No tables found in instance $instance"
    fi
    
    echo "  Disabling deletion protection for instance: $instance"
    gcloud bigtable instances update "$instance" --project="$project" --no-protection
    
    echo "  Deleting instance: $instance"
    gcloud bigtable instances delete "$instance" --project="$project" --quiet
  done
done
