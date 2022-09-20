# Cron

## How to run:
- cd into the Cron/Sources/Cron
- cat config.txt | swift main.swift 16:10

## I didn't have time to:
- To think of more edge cases and cover them in tests (and fix if unhandled)
- Define error enum with proper cases and use them instead of printing hardcoded strings like "Faulty data detected". This would also be useful in tests
- This package was supposed to run by this command 'cat config.txt | swift run Cron 16:10'. Which would have allowed me to separate implementation into different folders, but for unknown reasons the simulated time field was not picked up in stdin (CommandLine.arguments[safe: 1] was returning nil) and I could not figure it out in reasonable time period. When running 'cat config.txt | swift main.swift 16:10' exactly same code works fine. But, obviously if this was a proper app and a production code - I would not have everything in the same file and relevant classes/enums/interfaces would be created for service and utility layers (with dedicated folder/file management)

## Worth noting:
- In the example this time format was presented - 1:30 for /bin/run_me_daily. I assume that was intended formatting and it should be same for times like - 0:30
- HH:mm this is the expected time format for simulation if I'm not mistaken, in the requirements HH:MM was mentioned
- I implemented this in Xcode 14, hopefully this won't cause any issues for reviewer 
