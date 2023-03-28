@eventIDs = [
    [13,
        [28]
    ],
    [15,
        [21, 22, 23, 24]
    ],
    [17,
        [3]
    ],
    [40,
        [3, 6, 7, 9, 12, 13, 19, 21, 22, 23]
    ],
    [41,
        [24, 34]
    ],
    [45,
        [50, 51, 52, 55, 56, 57, 58]
    ],
    [46,
        [8]
    ],
    [79,
        [79, 81]
    ]
]

@eventPositionsToIgnore = [
    [17,
        [14, 10],
        [14, 12],
        [14, 13],
        [20, 10],
        [20, 11],
        [20, 12],
        [20, 13]
    ],
    [45,
        [25, 60],
        [25, 62],
        [58, 31],
        [60, 31],
        [70, 31],
        [72, 31]
    ],
    [46,
        [6, 37],
        [6, 38],
        [7, 37],
        [7, 38],
        [8, 37],
        [8, 38],
        [9, 37],
        [14, 37],
        [15, 37],
        [16, 37],
        [16, 38],
        [17, 37],
        [17, 38],
        [18, 37],
        [18, 38],
        [19, 37],
        [19, 38],
        [20, 37],
        [20, 38]
    ],
    [79,
        [8, 9],
        [8, 10],
        [9, 9],
        [9, 10],
        [10, 9],
        [10, 10],
        [11, 9],
        [16, 9],
        [17, 9],
        [18, 9],
        [18, 10],
        [19, 9],
        [19, 10],
        [20, 9],
        [20, 10],
        [21, 9],
        [21, 10],
        [22, 9],
        [22, 10]
    ]
]

EventHandlers.add(:on_player_step_taken, :graphic_transparency,
    proc {
        @map = $game_map.map_id
        @player_xy = [$game_player.x, $game_player.y]
        $gameEventSizes = [] if $gameEventSizes == nil
        checkEventSize() 
        checkPlayerPosition() if $gameEventSizes[@map] != nil
    }
)

def checkEventSize()
    eventSizes = []
    for i in 0...@eventIDs.length
        @getMapEventIDs = @eventIDs[i] if @eventIDs[i][0] == @map
    end
    for i in 0...@eventPositionsToIgnore.length
        @getMapPositionsToIgnore = @eventPositionsToIgnore[i][0] == @map && @eventPositionsToIgnore != nil ? @eventPositionsToIgnore[i] : [9999,9999]
    end
    if @getMapEventIDs != nil
        for i in 0...@getMapEventIDs[1].length
            event = $game_map.events[@getMapEventIDs[1][i]]
            eventSizes.push([[event.x, event.x + (event.width - 1)], [event.y, event.y - (event.height - 1)]]) if event != nil
        end
        $gameEventSizes[@map] = eventSizes == $gameEventSizes[@map] ? return : eventSizes
    end
end

def checkPlayerPosition()
    for i in 0...$gameEventSizes[@map].length
        for j in 0...@getMapPositionsToIgnore.length
            if @map == @getMapEventIDs[0]
                if @player_xy == @getMapPositionsToIgnore[j]
                    $game_system.map_interpreter.pbSetSelfSwitch(@getMapEventIDs[1][i],"A", false)
                    break
                else
                    $game_system.map_interpreter.pbSetSelfSwitch(@getMapEventIDs[1][i],"A",
                        @player_xy[1] <= $gameEventSizes[@map][i][1][0] && @player_xy[1] >= $gameEventSizes[@map][i][1][1] && @player_xy[0] >= $gameEventSizes[@map][i][0][0] && @player_xy[0] <= $gameEventSizes[@map][i][0][1]
                        )
                end
            end
        end
    end
end