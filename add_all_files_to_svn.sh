#!/bin/bash
svn status | awk '{ print $2 }' | xargs svn add
