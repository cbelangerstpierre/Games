Game4 = {}

function Game4:load()

    math.randomseed(os.time())
    WINDOW_WIDTH = 700
    WINDOW_HEIGHT = 650
    MARGE_WIDTH = 150
    SIDE_OF_SQUARE = (WINDOW_WIDTH - MARGE_WIDTH*2) / 8
    MARGE_HEIGHT = (WINDOW_HEIGHT - SIDE_OF_SQUARE*8)/2
    BLACK = "Black"
    WHITE = "White"
    EMPTY = "None"
    
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        resizable = false,
        fullscreen = false
    })
    love.window.setTitle("Othello")
    
    bigFont = love.graphics.newFont('Othello/fonts/ShortBaby-Mg2w.ttf', 48)
    smallFont = love.graphics.newFont("Othello/fonts/ShortBaby-Mg2w.ttf", 24)
    
    ROUNDRECT1x = WINDOW_WIDTH/2 - smallFont.getWidth(smallFont, "Player vs Player")/2 - 13
    ROUNDRECT1y = 270
    ROUNDRECT2x = WINDOW_WIDTH/2 - smallFont.getWidth(smallFont, "Player vs Computer")/2 - 13
    ROUNDRECT2y = 335

    sounds = {
        ['place'] = love.audio.newSource("Othello/sounds/place.wav", "static")
    }

    imgs = {
        ['roundrect'] = love.graphics.newImage("Othello/imgs/roundrect.png")
    }
    
    roundPositions = {
        [1] = {2,2},
        [2] = {6,2},
        [3] = {2,6},
        [4] = {6,6},
    }
    
    Game4:createGrid()
    
    pieces = {}
    for i = 1, 8, 1 do
        pieces[i] = {}
        for j = 1, 8, 1 do
            pieces[i][j] = EMPTY
        end
    end

    turnPossibilities = {
        [1] = {5,3},
        [2] = {6,4},
        [3] = {3,5},
        [4] = {4,6}
    }

    notWantedTurnPossibilities = {}

    blackCounter = 2
    whiteCounter = 2
    previousHadMove = true

    pieces[4][4] = WHITE
    pieces[4][5] = BLACK
    pieces[5][4] = BLACK
    pieces[5][5] = WHITE


    gameState = "choose"
    game = "" --or "computer"
    turn = WHITE
    otherTurn = BLACK
    winner = ""
    computer = ""
    computerTimer = 0
end

function Game4:createGrid()
    horizontalLines = {}
    verticalLines = {}
    for i = 0, 8, 1 do
        horizontalLines[i] = {
            MARGE_WIDTH,
            MARGE_HEIGHT + SIDE_OF_SQUARE * i,
            WINDOW_WIDTH - MARGE_WIDTH,
            MARGE_HEIGHT + SIDE_OF_SQUARE * i}

        verticalLines[i] = {
            i*SIDE_OF_SQUARE + MARGE_WIDTH,
            MARGE_HEIGHT,
            i*SIDE_OF_SQUARE + MARGE_WIDTH,
            WINDOW_HEIGHT - MARGE_HEIGHT}
    end
end

function Game4:keypressed(key)
    if gameState == "choose" then
        if key == "escape" then
            startTime = os.time()
            love.audio.stop()
            currentGame = 0
            loadMenu()
        end
    elseif gameState == "done" then
        if key == "enter" or key == "return" or key == "space" then
            Game4:restart()
        elseif key == "escape" then
            Game4:restart()
        end
    elseif gameState == "play" then
        if key == "m" then
            if soundsOn then
                soundsOn = false
                musicOn = false
            else
                soundsOn = true
                musicOn = true
            end
        elseif key == "escape" then
            Game4:restart()
        end
    end
end

function Game4:mouseInGame(x, y)
    if isBetween(x, MARGE_WIDTH, WINDOW_WIDTH-MARGE_WIDTH)
     and isBetween(y, MARGE_HEIGHT, WINDOW_HEIGHT-MARGE_HEIGHT) then
        return true
     else return false
    end
end

function Game4:cursorGridPos(x, y)
    for i = 1,8,1 do
        for j = 1,8,1 do
            if isBetween(x, MARGE_WIDTH+SIDE_OF_SQUARE*(i-1), MARGE_WIDTH+SIDE_OF_SQUARE*i)
            and isBetween(y, MARGE_HEIGHT+SIDE_OF_SQUARE*(j-1), MARGE_HEIGHT+SIDE_OF_SQUARE*j) then
                return {i,j}
            end
        end
    end
end

function flipPieces(piecesToFlip)
    for i = 1,tablelength(piecesToFlip), 1 do
        pieces[piecesToFlip[i][1]][piecesToFlip[i][2]] = turn
    end
end

function unflipPieces(piecesToUnflip)
    for i = 1,tablelength(piecesToUnflip), 1 do
        pieces[piecesToUnflip[i][1]][piecesToUnflip[i][2]] = otherTurn
    end
end

function Game4:mousepressed(x, y, button, istouch, presses)
    if gameState == "choose" then
        if button == 1 then
            if isBetween(x, ROUNDRECT1x, ROUNDRECT1x + 196)
             and isBetween(y, ROUNDRECT1y, ROUNDRECT1y + 49.2) then
                game = "player"
                gameState = "play"
            elseif isBetween(x, ROUNDRECT2x, ROUNDRECT2x + 225.4)
                and isBetween(y, ROUNDRECT2y, ROUNDRECT2y + 49.2) then
                game = "computer"
                if math.random(2) == 2 then
                    computer = BLACK
                else
                    computer = WHITE
                    computerTimer = os.time()
                end
                gameState = "play"
             end
        end
    elseif gameState == "play" then
        if not (computer == turn) then 
            if button == 1 and Game4:mouseInGame(x, y) then
                local pos = Game4:cursorGridPos(x, y)
                local xGrid, yGrid = pos[1], pos[2]
                if pieces[xGrid][yGrid] == EMPTY then
                    local piecesToFlip = Game4:validMove(xGrid, yGrid)
                    local empty = true
                    for i = 1,tablelength(piecesToFlip),1 do
                        if not (piecesToFlip[i] == {}) then
                            empty = false
                        end
                    end
                    if not empty then
                        flipPieces(piecesToFlip)
                        pieces[xGrid][yGrid] = turn
                        if soundsOn then
                            sounds['place']:clone():play()
                        end
                        if game == "computer" then
                            computerTimer = os.time()
                        end
                        previousHadMove = true
                        if turn == BLACK then
                            turn = WHITE
                            otherTurn = BLACK
                        elseif turn == WHITE then
                            turn = BLACK
                            otherTurn = WHITE
                        end
                        Game4:verifyPlayPossibility()
                    end
                end
            end
        end
    end
end

function Game4:verifyPlayPossibility()
    Game4:calculateTurnPossibilities()
    if tablelength(turnPossibilities) == 0 then
        if previousHadMove then
            previousHadMove = false
            local a = turn
            turn = otherTurn
            otherTurn = a
            Game4:calculateTurnPossibilities()
            if tablelength(turnPossibilities) == 0 then
                if whiteCounter > blackCounter then
                    winner = WHITE
                elseif blackCounter > whiteCounter then
                    winner = BLACK
                else
                    winner = "draw"
                end
                gameState = "done"
            end
        end
    end
end

function Game4:isACorner(position)
    if (position[1] == 1 and position[2] == 1)
    or (position[1] == 8 and position[2] == 1)
    or (position[1] == 8 and position[2] == 8)
    or (position[1] == 1 and position[2] == 8) then
        return true
    else
        return false
    end
end

function Game4:isASideThatFlipPieceinSide(position, position2)
    if (position[1] == 1
    or position[1] == 8
    or position[2] == 8
    or position[2] == 1) then
        if not Game4:isNotADangerousSide(position2) then
            return true
        else
            table.insert(notWantedTurnPossibilities, position2)
        end
    end
    return false
end

function Game4:isNotADangerousSide(position)
    if position[1] == 1
    or position[1] == 8
    or position[2] == 8
    or position[2] == 1 then
        if ((position[2] == 1 or position[2] == 8)
        and isBetween(position[1], 2, 7) and
        Game4:xor(pieces[position[1] - 1][position[2]] == otherTurn,
        pieces[position[1] + 1][position[2]] == otherTurn))
        or ((position[1] == 1 or position[1] == 8)
        and isBetween(position[2], 2, 7) and
        Game4:xor(pieces[position[1]][position[2] - 1] == otherTurn,
        pieces[position[1]][position[2] + 1] == otherTurn)) then
            table.insert(notWantedTurnPossibilities, position)
            return false
        else
            return true
        end
    end
    return false
end

function Game4:giveANiceMove(position)
    pieces[position[1]][position[2]] = turn
    a = turn
    b = otherTurn
    turn = b
    otherTurn = a
    initalTurnPossibilities = turnPossibilities
    piecesToFlip = Game4:validMove(position[1], position[2])
    flipPieces(piecesToFlip)
    Game4:calculateTurnPossibilities()
    for i = 1,tablelength(turnPossibilities),1 do
        if Game4:isACorner(turnPossibilities[i]) then
            table.insert(notWantedTurnPossibilities, 1, position)
        elseif Game4:isNotADangerousSide(turnPossibilities[i]) then
            table.insert(notWantedTurnPossibilities, position)
        end
    end
    flipPieces(piecesToFlip)
    turn = a
    otherTurn = b
    pieces[position[1]][position[2]] = EMPTY
    turnPossibilities = initalTurnPossibilities
end

function Game4:turnPossitibilitiesOfNextTurn(position)
    --Return the possibilities for the next move
end

function Game4:playTheMoveThatGivesTheLessMoves()

end

function Game4:godComputerMove()
    BestMove = {}
    MoveLevel = 100

    for i = 1,tablelength(turnPossibilities), 1 do
        local piecesToFlip = Game4:validMove(turnPossibilities[i][1], turnPossibilities[i][2])
        if Game4:isACorner(turnPossibilities[i]) then
            BestMove = turnPossibilities[i]
            MoveLevel = 1
        end
        for j = 1,tablelength(piecesToFlip),1 do
            if Game4:isASideThatFlipPieceinSide(piecesToFlip[j], turnPossibilities[i]) then
                if MoveLevel > 2 then
                    BestMove = turnPossibilities[i]
                    MoveLevel = 2
                end
            end
        end
        if Game4:isNotADangerousSide(turnPossibilities[i]) then
            if MoveLevel > 3 then
                BestMove = turnPossibilities[i]
                MoveLevel = 3
            end
        end
    end

    for i = 1, tablelength(notWantedTurnPossibilities), 1 do
        print(notWantedTurnPossibilities[i][1])
        print(notWantedTurnPossibilities[i][2])
    end

    if MoveLevel > 3 then
        for i = 1, tablelength(turnPossibilities), 1 do
            moveIsOk = true
            for j = 1, tablelength(notWantedTurnPossibilities), 1 do
                if notWantedTurnPossibilities[j][1] == turnPossibilities[i][1]
                and notWantedTurnPossibilities[j][2] == turnPossibilities[i][2] then
                    moveIsOk = false
                end
            end
            if moveIsOk then
                print(MoveLevel)
                print("Best from randoms")
                return turnPossibilities[i]
            end
        end
        print(MoveLevel)
        print("NOT WANTED")
        print()
        return notWantedTurnPossibilities[tablelength(notWantedTurnPossibilities)]
    else
        print(MoveLevel)
        print()
        return BestMove
    end

    -- if MoveLevel > 3 then
    --     return turnPossibilities[math.random(tablelength(turnPossibilities))]
    -- else
    --     return BestMove
    -- end

    

    -- if MoveLevel > 3 then
    --     if tablelength(notWantedTurnPossibilities) == 0 then
    --         goodPossibilities = turnPossibilities
    --     else
    --         goodPossibilities = {}
    --     end
    --     for i = 1,tablelength(turnPossibilities), 1 do
    --         Game4:giveANiceMove(turnPossibilities[i])
    --         for j = 1,tablelength(notWantedTurnPossibilities), 1 do
    --             print(notWantedTurnPossibilities[j], turnPossibilities[i])
    --             if not (notWantedTurnPossibilities[j] == turnPossibilities[i]) then
    --                 print("HEYYY")
    --                 table.insert(goodPossibilities, turnPossibilities[i])
    --             end
    --         end
    --     end
    --     if tablelength(goodPossibilities) == 0 then
    --         print(1000)
    --         return notWantedTurnPossibilities[tablelength(notWantedTurnPossibilities)]
    --     else
    --         print(2000)
    --         return goodPossibilities[math.random(tablelength(goodPossibilities))]
    --     end
    -- else
    --     print(MoveLevel)
    --     return BestMove
    -- end








    -- if tablelength(turnPossibilities) == 0 then
    --     return notWantedTurnPossibilities(tablelength(notWantedTurnPossibilities))
    -- else
    --     for i = 1,tablelength(turnPossibilities),1 do
    --         Game4:playTheMoveThatGivesTheLessMoves()
    --     end
    -- end
    -- if MoveLevel == 100 then
    --     print(MoveLevel)
    --     return turnPossibilities[math.random(tablelength(turnPossibilities))]
    -- else
    --     print(MoveLevel)
    --     return BestMove
    -- end
end

function Game4:computerPlay()
    if not (tablelength(turnPossibilities) == 0) then
        move = Game4:godComputerMove()
        notWantedTurnPossibilities = {}
        pieces[move[1]][move[2]] = turn
        flipPieces(Game4:validMove(move[1], move[2]))
        previousHadMove = true
        if turn == BLACK then
            turn = WHITE
            otherTurn = BLACK
        elseif turn == WHITE then
            turn = BLACK
            otherTurn = WHITE
        end
        if soundsOn then
            sounds['place']:clone():play()
        end
    end
    Game4:verifyPlayPossibility() 
    computerTimer = 0
end

function Game4:calculateTurnPossibilities()
    turnPossibilities = {}

    blackCounter = 0
    whiteCounter = 0
    for i = 1,8,1 do
        for j = 1,8,1 do
            if pieces[i][j] == EMPTY then
                piecesToFlip = Game4:validMove(i, j)
                local possible = false
                for k = 1,tablelength(piecesToFlip),1 do
                    if not (piecesToFlip[k] == {}) then
                        possible = true
                        break
                    end
                end

                if possible then
                    table.insert(turnPossibilities, {i,j})
                end
            elseif pieces[i][j] == BLACK then
                blackCounter = blackCounter + 1
            else
                whiteCounter = whiteCounter + 1
            end
        end
    end
end


function Game4:validMove(x, y) -- return the pos of the pieces that would be turned or false if there isnt
    piecesToFlip = {}

    --Horizontally 

    --Right
    for i = 2, 8-x, 1 do
        if pieces[x+i][y] == turn then
            local tmpPoss = {}
            for j = x+1, x+i-1, 1 do
                table.insert(tmpPoss, {j,y})
                if not (pieces[j][y] == otherTurn) then
                    tmpPoss = {}
                    break
                end
            end
            if not (tmpPoss == {}) then
                for i = 0,tablelength(tmpPoss),1 do
                    table.insert(piecesToFlip, tmpPoss[i])
                end
            end
            break
        end
    end


    --Left

    for i = -2, -x+1, -1 do
        if pieces[x+i][y] == turn then
            local tmpPoss = {}
            for j = x-1, x+i+1, -1 do
                table.insert(tmpPoss, {j,y})
                if not (pieces[j][y] == otherTurn) then
                    tmpPoss = {}
                    break
                end
            end
            if not (tmpPoss == {}) then
                for i = 0,tablelength(tmpPoss),1 do
                    table.insert(piecesToFlip, tmpPoss[i])
                end
            end
            break
        end
    end
    
    -- Vertically

    --above
    for i = 2, 8-y, 1 do
        if pieces[x][y+i] == turn then
            local tmpPoss = {}
            for j = y+1, y+i-1, 1 do
                table.insert(tmpPoss, {x, j})
                if not (pieces[x][j] == otherTurn) then
                    tmpPoss = {}
                    break
                end
            end
            if not (tmpPoss == {}) then
                for i = 0,tablelength(tmpPoss),1 do
                    table.insert(piecesToFlip, tmpPoss[i])
                end
            end
            break
        end
    end


     --under
    for i = -2, -y+1, -1 do
        if pieces[x][y+i] == turn then
            local tmpPoss = {}
            for j = y-1, y+i+1, -1 do
                table.insert(tmpPoss, {x, j})
                if not (pieces[x][j] == otherTurn) then
                    tmpPoss = {}
                    break
                end
            end
            if not (tmpPoss == {}) then
                for i = 0,tablelength(tmpPoss),1 do
                    table.insert(piecesToFlip, tmpPoss[i])
                end
            end
            break
        end
    end

    --Diagonally

    --TOP RIGHT
    if x-1 < 8-y then
        topRightLimit = x-1
    else
        topRightLimit = 8-y
    end
    for i = 2, topRightLimit, 1 do
        if pieces[x-i][y+i] == turn then
            local tmpPoss = {}
            for j = 1, i-1, 1 do
                table.insert(tmpPoss, {x-j, y+j})
                if not (pieces[x-j][y+j] == otherTurn) then
                    tmpPoss = {}
                    break
                end
            end
            if not (tmpPoss == {}) then
                for i = 0,tablelength(tmpPoss),1 do
                    table.insert(piecesToFlip, tmpPoss[i])
                end
            end
            break
        end
    end
    
    --TOP LEFT
    if 8-x < 8-y then
        topLeftLimit = 8-x
    else
        topLeftLimit = 8-y
    end
    for i = 2, topLeftLimit, 1 do
        if pieces[x+i][y+i] == turn then
            local tmpPoss = {}
            for j = 1, i-1, 1 do
                table.insert(tmpPoss, {x+j, y+j})
                if not (pieces[x+j][y+j] == otherTurn) then
                    tmpPoss = {}
                    break
                end
            end
            if not (tmpPoss == {}) then
                for i = 0,tablelength(tmpPoss),1 do
                    table.insert(piecesToFlip, tmpPoss[i])
                end
            end
            break
        end
    end
    
    --BOTTOM RIGHT
    if x-1 < y-1 then
        bottomRightLimit = x-1
    else
        bottomRightLimit = y-1
    end
    for i = 2, bottomRightLimit, 1 do
        if pieces[x-i][y-i] == turn then
            local tmpPoss = {}
            for j = 1, i-1, 1 do
                table.insert(tmpPoss, {x-j, y-j})
                if not (pieces[x-j][y-j] == otherTurn) then
                    tmpPoss = {}
                    break
                end
            end
            if not (tmpPoss == {}) then
                for i = 0,tablelength(tmpPoss),1 do
                    table.insert(piecesToFlip, tmpPoss[i])
                end
            end
            break
        end
    end
    
    --BOTTOM LEFT
    if 8-x < y-1 then
        bottomLeftLimit = 8-x
    else
        bottomLeftLimit = y-1
    end
    for i = 2, bottomLeftLimit, 1 do
        if pieces[x+i][y-i] == turn then
            local tmpPoss = {}
            for j = 1, i-1, 1 do
                table.insert(tmpPoss, {x+j, y-j})
                if not (pieces[x+j][y-j] == otherTurn) then
                    tmpPoss = {}
                    break
                end
            end
            if not (tmpPoss == {}) then
                for i = 0,tablelength(tmpPoss),1 do
                    table.insert(piecesToFlip, tmpPoss[i])
                end
            end
            break
        end
    end

    return piecesToFlip
end


function Game4:update(dt)
    if (computerTimer == 0 or os.time() > computerTimer + 1) and game == "computer" and computer == turn then
        Game4:computerPlay()
    end
end

function Game4:draw()
    love.graphics.setFont(bigFont)
    love.graphics.setColor({1,1,1})
    love.graphics.printf("Othello", 0, 10, WINDOW_WIDTH, "center")
    love.graphics.setFont(smallFont)
    if gameState == "choose" then
        love.graphics.draw(imgs['roundrect'], ROUNDRECT1x, ROUNDRECT1y, 0, 0.2, 0.15)
        love.graphics.draw(imgs['roundrect'], ROUNDRECT2x, ROUNDRECT2y, 0, 0.23, 0.15)
        love.graphics.printf("Player vs Player", 0, WINDOW_HEIGHT/2 - smallFont.getHeight(smallFont) - 20, WINDOW_WIDTH, "center")
        love.graphics.printf("Player vs Computer", 0, WINDOW_HEIGHT/2 +20, WINDOW_WIDTH, "center")
    else
        if gameState == "done" then
            love.graphics.printf("'Enter' to restart", 0, MARGE_HEIGHT-smallFont.getHeight(smallFont) - 10, WINDOW_WIDTH, "center")
        end
        if winner == "" and computer == turn then
            love.graphics.printf("Computer turn", 0, WINDOW_HEIGHT-10-smallFont.getHeight(smallFont), WINDOW_WIDTH, "center")
        elseif winner == "" then
            love.graphics.printf(turn .. " turn", 0, WINDOW_HEIGHT-10-smallFont.getHeight(smallFont), WINDOW_WIDTH, "center")
        elseif winner == "draw" then
            love.graphics.printf("No winner, this is a " .. winner, 0, WINDOW_HEIGHT-10-smallFont.getHeight(smallFont), WINDOW_WIDTH, "center")
        else
            love.graphics.printf(winner .. " is the winner", 0, WINDOW_HEIGHT-10-smallFont.getHeight(smallFont), WINDOW_WIDTH, "center")
        end
        love.graphics.printf(whiteCounter, 20, (WINDOW_HEIGHT-smallFont.getHeight(smallFont))/2, WINDOW_WIDTH, "left")
        love.graphics.printf(blackCounter, 20, (WINDOW_HEIGHT+smallFont.getHeight(smallFont))/2, WINDOW_WIDTH, "left")
        love.graphics.circle("fill", 20 + 20 + smallFont.getWidth(smallFont, whiteCounter), (WINDOW_HEIGHT-smallFont.getHeight(smallFont))/2 + 10, 10)
        love.graphics.circle("line", 20 + 20 + smallFont.getWidth(smallFont, blackCounter), (WINDOW_HEIGHT+smallFont.getHeight(smallFont))/2 + 10, 10)
        love.graphics.setColor({0,0,0})
        love.graphics.circle("fill", 20 + 20 + smallFont.getWidth(smallFont, blackCounter), (WINDOW_HEIGHT+smallFont.getHeight(smallFont))/2 + 10, 10)
        
        love.graphics.setColor{15/255, 130/255, 0/255}
        love.graphics.rectangle(
            "fill",
            MARGE_WIDTH,
            MARGE_HEIGHT,
            WINDOW_WIDTH - MARGE_WIDTH * 2,
            WINDOW_HEIGHT - MARGE_HEIGHT * 2)
        love.graphics.setColor({1,1,1})
        love.graphics.rectangle(
            "line",
            MARGE_WIDTH-1,
            MARGE_HEIGHT-1,
            WINDOW_WIDTH - MARGE_WIDTH * 2+2,
            WINDOW_HEIGHT - MARGE_HEIGHT * 2+2)
        love.graphics.setColor{0, 0, 0}
        for i = 0, 8, 1 do
            love.graphics.line(horizontalLines[i])
            love.graphics.line(verticalLines[i])
        end
    
        for i = 1, 4, 1 do
            love.graphics.circle(
            "fill",
            MARGE_WIDTH + SIDE_OF_SQUARE*roundPositions[i][1],
            MARGE_HEIGHT + SIDE_OF_SQUARE*roundPositions[i][2],
            5)
        end
    
        for i = 1,8,1
        do
            for j = 1,8,1
            do
                if pieces[i][j] == BLACK then
                    love.graphics.setColor({0,0,0})
                elseif pieces[i][j] == WHITE then
                    love.graphics.setColor({1,1,1})
                end
                if not (pieces[i][j] == EMPTY) then
                    love.graphics.circle("fill",
                        MARGE_WIDTH + SIDE_OF_SQUARE*(i-0.5),
                        MARGE_HEIGHT + SIDE_OF_SQUARE*(j-0.5),
                        20)
                end
            end
        end
    
        for i = 1,tablelength(turnPossibilities), 1 do
            love.graphics.setColor(69/255, 69/255, 69/255, 0.5)
            love.graphics.circle(
                "fill",
                MARGE_WIDTH + SIDE_OF_SQUARE*(turnPossibilities[i][1] - 0.5),
                MARGE_HEIGHT + SIDE_OF_SQUARE*(turnPossibilities[i][2] - 0.5),
            10)
        end
    end

    Game4:displayFPS()
end

function Game4:displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function Game4:restart()
    pieces = {}
    for i = 1, 8, 1 do
        pieces[i] = {}
        for j = 1, 8, 1 do
            pieces[i][j] = EMPTY
        end
    end

    turnPossibilities = {
        [1] = {5,3},
        [2] = {6,4},
        [3] = {3,5},
        [4] = {4,6}
    }

    blackCounter = 2
    whiteCounter = 2
    previousHadMove = true

    pieces[4][4] = WHITE
    pieces[4][5] = BLACK
    pieces[5][4] = BLACK
    pieces[5][5] = WHITE


    gameState = "choose"
    game = "" --or "computer"
    turn = WHITE
    otherTurn = BLACK
    winner = ""
    computer = ""
    computerTimer = 0
end

function Game4:xor(a,b)
    return (a or b) and not (a and b)
   end 

return Game4