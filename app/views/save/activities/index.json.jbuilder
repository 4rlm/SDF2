# json.array! @activities, partial: 'activities/activity', as: :activity
json.partial! partial: 'activities/activity', collection: @activities, as: :activity
