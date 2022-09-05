module.AddMarker = function(playerId, options)
    event.trigger("marker:addMarker", playerId, options);
end

module.RemoveMarker = function(playerId, id)
    event.trigger("marker:removeMarker", playerId, id);
end