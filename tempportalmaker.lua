require "tprint"
require "pluginhelper"

function beacon_time(name, line, wildcards)
    local hour = tonumber(wildcards.hour)
    local minute = tonumber(wildcards.minute)
    local second = tonumber(wildcards.second)
    AddTimer ('portaldel', hour, minute, second, 'echo deleting temp portal', 1029, 'portaldel')
    EnableTrigger('beacon_time_trig', 0)
end

function portal_handle(name, line, wildcards)
    res, gmcparg = CallPlugin("3e7dedbe37e44942dd46d264", "gmcpval", "room") --- We just want the gmcp.char section.
    luastmt = "gmcpdata = " .. gmcparg --- Convert the serialized string back into a lua table.
    assert (loadstring (luastmt or "")) ()
    if (GetTimerInfo("portaldel", 1) ~= nil) then
        portaldel()
    end
    DeleteTimer('portaldel')
    Send('c beacon')
    if wildcards[1] ~= '' then
        print('here')
        if tonumber(wildcards[1] == nil) then
            print('Try homePortal <number>')
            return
        end
        Execute ('mapper fullportal {c homecom} {'..tonumber(wildcards[1]) .. '} 0')
    else
        Execute ('mapper fullportal {c homecom} {'..gmcpdata.info.num..'} 0')
    end
    -- this is wher eyou will need to add a check for time of beacon life
    EnableTrigger('beacon_time_trig', 1)
    Execute('beacon')
    --AddTimer ( 'portaldel' , 2 , 15 , 0 , 'echo deleting temp portal' , 1029 , 'portaldel' )
end
function portaldel()
    Execute('mapper delete portal c homecom')
end
function portaldelpet()
    Execute('mapper delete portal c door ' .. GetVariable('pet'))
end
function portal_handle_pet(name, line, wildcards)
    local petname = GetVariable('pet')
    if petname == nil or petname == '' then
        Note('pet was nil')
        petname = wildcards[1]
        SetVariable('pet', petname)
    else
        Note(petname)
    end
    res, gmcparg = CallPlugin("3e7dedbe37e44942dd46d264", "gmcpval", "room") --- We just want the gmcp.char section.
    luastmt = "gmcpdata = " .. gmcparg --- Convert the serialized string back into a lua table.
    assert (loadstring (luastmt or "")) ()
    
    portaldelpet()
    
    Send('heel')
    Send('order '..petname..' sit')
    Execute ('mapper fullportal {c door '..wildcards[1] .. '} {'..gmcpdata.info.num..'} 0')
end
function do_Execute_no_echo(command)
    local original_echo_setting = GetOption("display_my_input")
    SetOption("display_my_input", 0)
    Execute(command)
    SetOption("display_my_input", original_echo_setting)
end
function clearPortals()
    Execute('mapper delete portal c homecom')
    Execute('mapper delete portal c door')
end
function clearPortalHome()
    DeleteTimer('portaldel')
    Execute('mapper delete portal c homecom')
end
function clearPortalPet()
    Execute('mapper delete portal c door ' .. GetVariable('pet'))
    SetVariable('pet', '')
end
function help()
    print ('Commands are:')
    print(' -- homePortal, this can take a room number or leave it out, will autocast beacon of homecomming.')
    print(' -- petPortal, this takes the mob name as "petPortal slobcat"')
    print(' --clearPortals')
    print(' --clearPetPortal')
    print(' --clearHomePortal')
    
end
