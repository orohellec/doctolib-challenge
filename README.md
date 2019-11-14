# Doctolib-challenge

## Problematic

The goal is to write an algorithm that finds availabilities in an agenda depending on the events attached to it. The main method has a start date for input and is looking for the availabilities over the next 7 days.

## My solution

1. I created a method to get the events that occurs in the next seven days
2. I isolated the opened events from the appointed events
3. I transformed the opened and appointed events in two separate hashes of this format: {1: [9h30, 10h00], 4: [12h00] } . Keys represents a day of the week (date.wday) and values correspond to slots. 
4. I found the vacant slots by removing the open slots presents in the booked slots for the same day
5. Finaly, I output an array of hash. Each hash contains date and slots associated {date: start_date.to_date + n days, slots: vacant_slots[date.wday]}





