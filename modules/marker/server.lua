module.AddMarker = function(playerId, type, pos, distance, color, dir, rot, scale, bob, faceCamera, rotate)
    event.trigger("marker:addMarker", playerId, type, pos, distance, color, dir, rot, scale, bob, faceCamera, rotate);
end

module.RemoveMarker = function(playerId, id)
    event.trigger("marker:removeMarker", playerId, id);
end