class Event < ApplicationRecord
  def self.availabilities(start_date)
    events = get_events_in_the_next_seven_days(start_date)
    opening_events = events.select { |event| event.kind == 'opening' }
    appointed_events = events.select { |event| event.kind == 'appointment' }
    appointed_events_hash = hash_events(appointed_events)
    opened_events_hash = hash_events(opening_events)
    vacant_slots = find_vacant_slots(appointed_events_hash, opened_events_hash)
    output_vacant_slots_by_date(start_date, vacant_slots)
  end

  def convert_time_in_slots
    slots = []
    until self.starts_at >= self.ends_at
      slots << starts_at.strftime("%H:%M").to_s
      self.starts_at += 30.minutes
    end
    slots
  end

  def self.get_events_in_the_next_seven_days(start_date)
    end_date = start_date + 7.days
    Event.where(starts_at: start_date...end_date)
            .or(where(weekly_recurring: true))
  end

  private_class_method def self.hash_events(events)
    events_hash = {}
    events.each do |event|
      day_of_the_week = event.starts_at.to_date.wday
      if events_hash[day_of_the_week]
        slots_event = event.convert_time_in_slots
        merged_slots = events_hash[day_of_the_week] + slots_event
        events_hash[day_of_the_week] = merged_slots
      else
        slots_event = event.convert_time_in_slots
        events_hash[day_of_the_week] = slots_event
      end
    end
    events_hash
  end

  private_class_method def self.find_vacant_slots(appointed_events_hash, opened_events_hash)
    vacant_slots = {}
    for i in 0..6 do
      open_slots = opened_events_hash[i]
      booked_slots = appointed_events_hash[i]
      if open_slots
        if !booked_slots
          vacant_slots[i] = open_slots
        else
          vacant_slots[i] = open_slots - booked_slots
        end
      end
    end
    vacant_slots
  end

  private_class_method def self.output_vacant_slots_by_date(start_date, vacant_slots)
    output = []
    7.times do |n|
      date = start_date.to_date + n.days
      if vacant_slots[date.wday]
        output << {
          date: date,
          slots: vacant_slots[date.wday]
        }
      else
        output << {
          date: date,
          slots: []
        }
      end
    end
    output
  end
end
