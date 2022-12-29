function onCountdownTick(counter)
    if counter == 2 then
        characterPlayAnim('boyfriend', 'pre-attack', true)
    end

    if counter == 3 then
        characterPlayAnim('boyfriend', 'hey', true)
        characterPlayAnim('gf', 'cheer', true)
    end
end