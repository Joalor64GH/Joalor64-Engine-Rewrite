function onUpdatePost(elapsed)
	--https://scriptinghelpers.org/questions/78269/is-it-possible-to-generate-a-random-string-of-numbers-letters-and-symbols

	local upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local lowerCase = string.lower(upperCase)
	local numbers = "0123456789"
	local symbols = "!@#$%&()*+-,./:;<=>?^[]{}"

	local characterSet = upperCase .. lowerCase .. numbers .. symbols

	local keyLength = 32 --change to get larger or smaller string lengths
	local output = ""

	for i = 1, keyLength do
	local rand = math.random(#characterSet)
	output = output .. string.sub(characterSet, rand, rand)
	end

	setPropertyFromClass("openfl.Lib", "application.window.title", output)
end