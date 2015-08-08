#!/bin/bash
gosu postgres createuser dolphin -s -l
gosu postgres createdb dolphin -lC -EUTF8 -Ttemplate0
