@eventIDs = [
    [13,
        [28, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]
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
        [2, 3, 5, 9, 11, 12, 13, 24, 25, 26, 27]
    ],
    [45,
        [50, 51, 52, 56, 57]
    ],
    [46,
        [8]
    ],
    [79,
        [79, 81]
    ]
]

@eventPositionsToIgnore = [
    [13,
        [2, 35],
        [10, 35],
        [14, 35],
        [18, 35],
        [22, 35],
        [27, 32],
        [28, 37],
        [29, 16],
        [30, 11],
        [32, 11],
        [32, 37],
        [36, 38],
        [40, 11],
        [40, 38],
        [42, 11],
        [42, 38],
        [42, 39],
        [43, 16],
        [43, 38],
        [43, 39],
        [44, 38],
        [44, 39],
        [45, 38],
        [45, 39],
        [46, 38],
        [50, 38],
        [51, 38],
        [52, 38],
        [53, 38],
        [53, 39],
        [54, 38],
        [54, 39],
        [55, 38],
        [55, 39],
        [56, 38],
        [56, 39],
        [57, 38],
        [57, 39]
    ],
    [17,
        [14, 10],
        [14, 12],
        [14, 13],
        [20, 10],
        [20, 11],
        [20, 12],
        [20, 13]
    ],
    [41,
        [9, 7],
        [9, 8],
        [9, 9],
        [9, 10],
        [9, 11],
        [10, 7],
        [10, 8],
        [10, 9],
        [10, 10],
        [10, 11],
        [11, 7],
        [11, 8],
        [11, 9],
        [11, 10],
        [11, 11],
        [12, 7],
        [12, 8],
        [12, 9],
        [12, 10],
        [12, 11],
        [13, 7],
        [13, 8],
        [13, 9],
        [13, 10],
        [13, 11],
        [14, 7],
        [14, 8],
        [14, 9],
        [14, 10],
        [14, 11],
        [15, 7],
        [15, 8],
        [15, 9],
        [15, 10],
        [15, 11],
        [16, 7],
        [16, 8],
        [16, 9],
        [16, 10],
        [16, 11],
        [17, 7],
        [17, 8],
        [17, 9],
        [17, 10],
        [17, 11],
        [18, 7],
        [18, 8],
        [18, 9],
        [18, 10],
        [18, 11],
        [19, 7],
        [19, 8],
        [19, 9],
        [19, 10],
        [19, 11],
        [20, 7],
        [20, 8],
        [20, 9],
        [20, 10],
        [20, 11],
        [21, 7],
        [21, 8],
        [21, 9],
        [21, 10],
        [21, 11],
        [22, 11],
        [26, 8],
        [26, 11],
        [26, 12],
        [26, 13],
        [26, 16]
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
        if @eventPositionsToIgnore[i][0] == @map && @eventPositionsToIgnore[i] != nil
            @getMapPositionsToIgnore = @eventPositionsToIgnore[i]
            break 
        else
            @getMapPositionsToIgnore = [9999,9999]
        end
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