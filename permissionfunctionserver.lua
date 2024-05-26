local frozenPlayers = {}
AdminFunctions = {
    CodemStaffMenuAdminRevive = function(data)
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            local xPlayer = GetPlayer(data.targetID)
            if xPlayer then
                TriggerClientEvent('esx_ambulancejob:revive', tonumber(data.targetID))
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerrevived'])
            end
        else
            local xPlayer = GetPlayer(data.targetID)
            if xPlayer then
                TriggerClientEvent('hospital:client:Revive', tonumber(data.targetID))
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerrevived'])
            end

            if discord_webhook["revive"].allow and discord_webhook["revive"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["revive"].text, 'revive')
            end
        end
    end,
    CodemStaffMenuHeal = function(data)
        local src = data.targetID
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:healPlayer', src)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerhealed'])
            if discord_webhook["heal"].allow and discord_webhook["heal"].webhook ~= "" then
                discordLogStaff(tonumber(src), tonumber(data.targetID), discord_webhook["heal"].text, 'heal')
            end
        end
    end,
    CodemStaffMenuKill = function(data)
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            local xPlayer = GetPlayer(data.targetID)
            if xPlayer then
                TriggerClientEvent('esx:killPlayer', data.targetID)
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerkilled'])
            end
        else
            local xPlayer = GetPlayer(data.targetID)
            if xPlayer then
                TriggerClientEvent('hospital:client:KillPlayer', data.targetID)
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerkilled'])
            end
            if discord_webhook["kill"].allow and discord_webhook["kill"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["kill"].text, 'kill')
            end
        end
    end,
    CodemStaffMenuFreeze = function(data)
        local targetID = tonumber(data.targetID)
        local xPlayer = GetPlayer(targetID)
        if xPlayer then
            if frozenPlayers[targetID] then
                frozenPlayers[targetID] = false
                FreezeEntityPosition(tonumber(data.targetID), false)
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerunfrozen'])
                if discord_webhook["freeze"].allow and discord_webhook["freeze"].webhook ~= "" then
                    discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["freeze"].text2,
                        'freeze')
                end
            else
                frozenPlayers[targetID] = true
                FreezeEntityPosition(targetID, true)
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerfrozen'])
                if discord_webhook["freeze"].allow and discord_webhook["freeze"].webhook ~= "" then
                    discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["freeze"].text, 'freeze')
                end
            end
        end
    end,
    CodemStaffMenuGoto = function(data)
        local src = data.src
        local staff = GetPlayerPed(src)
        local xTargetPed = GetPlayerPed(data.targetID)
        local coords = GetEntityCoords(xTargetPed)
        if staff and xTargetPed then
            SetEntityCoords(staff, coords)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playergoto'])
            if discord_webhook["goto"].allow and discord_webhook["goto"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["goto"].text .. coords,
                    'goto')
            end
        end
    end,
    CodemStaffMenuBring = function(data)
        local src = data.src
        local staff = GetPlayerPed(src)
        local xTarget = GetPlayerPed(data.targetID)
        local coords = GetEntityCoords(staff)
        if staff and xTarget then
            SetEntityCoords(xTarget, coords)
            if discord_webhook["bring"].allow and discord_webhook["bring"].webhook ~= "" then
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerbring'])
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["bring"].text .. coords,
                    'bring')
            end
        end
    end,
    CodemStaffMenuGiveClothingMenu = function(data)
        TriggerClientEvent('codem-staffmenu:openClothingMenu', data.targetID)
        TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerclothes'])
        if discord_webhook["clothingmenu"].allow and discord_webhook["clothingmenu"].webhook ~= "" then
            discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["clothingmenu"].text,
                'clothingmenu')
        end
    end,
    CodemStaffMenuGiveVIP = function(data)
        local targetID = data.targetID
        local xPlayer = GetPlayer(data.targetID)
        local identifier = GetIdentifier(targetID)
        if xPlayer then
            playerServerData[identifier].rankdata.vip = not playerServerData[identifier].rankdata.vip
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playervip'])
            TriggerClientEvent('codem-staff:updateplayervip', data.src, data.targetID,
                playerServerData[identifier].rankdata.vip)
            if discord_webhook["givevip"].allow and discord_webhook["givevip"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["givevip"].text, 'givevip')
            end
        end
    end,
    CodemStaffMenuKickAll = function(data)
        src = tonumber(data.src)
        if #data.reason < 1 then
            data.reason = "No Reason"
        end
        for _, playerId in ipairs(GetPlayers()) do
            if tonumber(playerId) ~= src then
                DropPlayer(playerId, data.reason)
            else
                TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['allkick'])
                local adminidentifier = GetIdentifier(src)
                updateAdminLogData(adminidentifier, 'kick')
                if discord_webhook["allkick"].allow and discord_webhook["allkick"].webhook ~= "" then
                    discordLogStaff(tonumber(data.src), tonumber(data.src), discord_webhook["allkick"].text, 'allkick')
                end
            end
        end
    end,
    CodemStaffMenuKickPlayer = function(data)
        local src = data.src
        local zTarget = data.targetID
        local xPlayer = GetPlayer(src)
        local zPlayer = GetPlayer(zTarget)
        if tonumber(data.src) == tonumber(data.targetID) then
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['selfkick'])
            return
        end
        if xPlayer and zPlayer then
            local identifier = GetIdentifier(zTarget)
            local adminidentifier = GetIdentifier(src)
            local serverdata = playerServerData[identifier]
            if not serverdata then
                TriggerClientEvent('codem-staff:notification', src,
                    string.format(Config.BackendLocales['playerdatanotfound'], identifier))
                return
            end
            local adminname = playerServerData[adminidentifier].profiledata.name or "Unknown"


            if not data.reason or #data.reason < 1 then
                data.reason = "No Reason"
            end
            local message = "You have been kicked from the server for " .. data.reason .. " by " .. adminname
            local historydata = serverdata.historydata
            if type(historydata) == "table" and not historydata.kick then
                historydata.kick = {}
            end
            local history = {
                reason = data.reason,
                admin = adminname,
                avatar = serverdata.profiledata.avatar or Config.ExampleProfilePicture,
                time = os.date("%m.%d.%Y %I:%M")
            }
            table.insert(historydata.kick, history)
            serverdata.historydata = historydata
            Citizen.Wait(100)
            TriggerClientEvent('codem-staffmenu:updateBanKickdata', src,
                { historydata = serverdata.historydata, playerid = zTarget })
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['playerkick'])

            DropPlayer(zTarget, message)
            ExecuteSql(
                'UPDATE codem_staff_playersdata SET historydata = :historydata WHERE identifier = :identifier',
                {
                    identifier = identifier,
                    historydata = json.encode(serverdata.historydata)
                }
            )

            updateAdminLogData(adminidentifier, 'kick')
            if discord_webhook["kick"].allow and discord_webhook["kick"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["kick"].text .. data.reason,
                    'kick')
            end
        end
    end,
    CodemStaffMenuJailPlayer = function(data)
        local src = tonumber(data.src)
        local zTarget = tonumber(data.targetID)
        local xPlayer = GetPlayer(src)
        local zPlayer = GetPlayer(zTarget)
        if xPlayer and zPlayer then
            local identifier = GetIdentifier(zTarget)
            local adminidentifier = GetIdentifier(src)
            local serverdata = playerServerData[identifier]

            if not serverdata then
                TriggerClientEvent('codem-staff:notification', src,
                    string.format(Config.BackendLocales['playerdatanotfound'], identifier))
                return
            end
            if serverdata.profiledata.JailTime > 0 then
                TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['playerjailed'])
                return
            end

            if src == zTarget then
                TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['selfjail'])
                return
            end

            jailTime = 0
            hour = tonumber(data.hour)
            min = tonumber(data.min)
            if hour == 0 and min == 0 then
                jailTime = 0
                return
            else
                if hour or min then
                    if hour >= 1 and min == 0 then
                        jailTime = hour * 3600
                    elseif min >= 1 and hour == 0 then
                        jailTime = min * 60
                    elseif hour >= 1 and min >= 1 then
                        jailTime = hour * 3600 + min * 60
                    end
                end
            end




            local adminname = playerServerData[adminidentifier].profiledata.name or "Unknown"

            if not data.reason or #data.reason < 1 then
                data.reason = "No Reason"
            end

            local historydata = serverdata.historydata
            if type(historydata) == "table" and not historydata.jail then
                historydata.jail = {}
            end
            serverdata.profiledata.JailTime = jailTime

            local history = {
                reason = data.reason,
                admin = adminname,
                avatar = serverdata.profiledata.avatar or Config.ExampleProfilePicture,
                time = os.date("%m.%d.%Y %I:%M"),
                jailtime = jailTime,
            }

            table.insert(historydata.jail, history)
            serverdata.historydata = historydata
            Citizen.Wait(100)
            SetEntityCoords(zTarget, Config.JailCoords)
            TriggerClientEvent('codem-staffmenu:updateBanKickdata', src,
                { historydata = serverdata.historydata, playerid = zTarget })
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['playerjailed'])
            TriggerClientEvent('codem-staffmenu:client:sendToJail', zTarget, jailTime)
            local adminidentifier = GetIdentifier(src)
            updateAdminLogData(adminidentifier, 'jail')
            if discord_webhook["jail"].allow and discord_webhook["jail"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["jail"].text .. data.reason,
                    'jail')
            end
            ExecuteSql(
                'UPDATE codem_staff_playersdata SET historydata = :historydata, profiledata = :profiledata WHERE identifier = :identifier',
                {
                    identifier = identifier,
                    historydata = json.encode(serverdata.historydata),
                    profiledata = json.encode(serverdata.profiledata)
                }
            )
        end
    end,
    CodemStaffMenuSetjob = function(data)
        local jobname = data.jobname
        if data.jobgrade == false then
            data.jobgrade = 0
        end
        local jobgrade = tonumber(data.jobgrade)
        local src = data.targetID
        local xPlayer = GetPlayer(src)
        if xPlayer then
            if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                xPlayer.setJob(jobname, jobgrade)
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerjobchanged'])
            else
                xPlayer.Functions.SetJob(jobname, jobgrade)
                TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['playerjobchanged'])
            end
            jobName = GetJob(src)
            jobGrade = GetJobGrade(src)
            TriggerClientEvent('codem-staffmenu:updatePlayerJob', data.src, jobName, jobGrade)
            if discord_webhook["setjob"].allow and discord_webhook["setjob"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID),
                    discord_webhook["setjob"].text .. " " .. jobname .. " " .. data.jobgrade, 'setjob')
            end
        end
    end,
    CodemStaffMenuClearInventory = function(data)
        local src = tonumber(data.src)
        local targetID = tonumber(data.targetID)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            clearInventory(targetID)
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['clearinventory'])
            if discord_webhook["clearinv"].allow and discord_webhook["clearinv"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["clearinv"].text,
                    'clearinv')
            end
        end
    end,
    CodemStaffMenuScreenShot = function(data)
        local src = tonumber(data.src)
        local targetID = tonumber(data.targetID)
        if discord_webhook["takescreenshot"].allow and discord_webhook["takescreenshot"].webhook ~= "" then
            TriggerClientEvent('codem-staffmenu:takePicture', targetID, discord_webhook["takescreenshot"].webhook)
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['takescreenshot'])
        end
    end,
    CodemStafMenuMarkPlayer = function(data)
        local src = tonumber(data.src)
        local xTarget = GetPlayerPed(data.targetID)
        local coords = GetEntityCoords(xTarget)
        if src and xTarget then
            TriggerClientEvent("codem-staffmenu:markPlayer", src, coords)
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['markplayer'])
        end
    end,
    CodemStaffSpectatePlayer = function(data)
        local xTarget = GetPlayerPed(data.targetID)
        local coords = GetEntityCoords(xTarget)
        local targetIdentifier = GetIdentifier(data.targetID)
        if tonumber(data.src) == tonumber(data.targetID) then
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['spectateyourself'])
            return
        end
        local spectatePlayerTable = {
            avatar   = playerServerData[targetIdentifier].profiledata.avatar or Config.ExampleProfilePicture,
            name     = GetName(data.targetID) or "Unknown",
            targetID = data.targetID,
            vip      = playerServerData[targetIdentifier].rankdata.vip or false,
            ping     = GetPlayerPing(data.targetID),
            steam    = playerServerData[targetIdentifier].profiledata.steam or "Not Found",
            discord  = playerServerData[targetIdentifier].profiledata.discord or "Not Found",
            license  = playerServerData[targetIdentifier].profiledata.license or "Not Found",
            job      = GetJob(data.targetID)
        }
        TriggerClientEvent('codem-staff:spectatePlayer', data.src, data.targetID, coords, spectatePlayerTable)
        TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['spectateplayer'])
        if discord_webhook["spectateplayer"].allow and discord_webhook["spectateplayer"].webhook ~= "" then
            discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["spectateplayer"].text,
                'spectateplayer')
        end
    end,

    CodemStaffMenuWarnPlayer = function(data)
        local src = data.src
        local zTarget = data.targetID
        local xPlayer = GetPlayer(src)
        local zPlayer = GetPlayer(zTarget)
        if tonumber(data.src) == tonumber(data.targetID) then
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['selfwarn'])
            return
        end
        if xPlayer and zPlayer then
            local identifier = GetIdentifier(zTarget)
            local adminidentifier = GetIdentifier(src)
            local serverdata = playerServerData[identifier]
            if not serverdata then
                TriggerClientEvent('codem-staff:notification', src,
                    'player data not found for identifier : ' .. identifier)
                return
            end
            if #data.reason < 1 then
                data.reason = "No Reason"
            end
            TriggerClientEvent('codem-staffmenu:warn', data.targetID, data.reason or "No Reason")
            local adminname = playerServerData[adminidentifier].profiledata.name or "Unknown"
            local historydata = serverdata.historydata
            if type(historydata) == "table" and not historydata.warn then
                historydata.warn = {}
            end
            local history = {
                reason = data.reason or "No Reason",
                admin = adminname,
                avatar = serverdata.profiledata.avatar or Config.ExampleProfilePicture,
                time = os.date("%m.%d.%Y %I:%M")
            }
            table.insert(historydata.warn, history)
            serverdata.historydata = historydata
            Citizen.Wait(100)
            TriggerClientEvent('codem-staffmenu:updateBanKickdata', src,
                { historydata = serverdata.historydata, playerid = zTarget })
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['playerwarned'])

            updateAdminLogData(adminidentifier, 'warn')
            ExecuteSql(
                'UPDATE codem_staff_playersdata SET historydata = :historydata WHERE identifier = :identifier',
                {
                    identifier = identifier,
                    historydata = json.encode(serverdata.historydata)
                }
            )
            if discord_webhook["warn"].allow and discord_webhook["warn"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID), discord_webhook["warn"].text .. data.reason,
                    'warn')
            end
        end
    end,

    CodemStaffMenuAllRevive = function(data)
        local src = data.src
        for _, playerId in ipairs(GetPlayers()) do
            if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                local xPlayer = GetPlayer(tonumber(playerId))
                if xPlayer then
                    TriggerClientEvent('esx_ambulancejob:revive', tonumber(playerId))
                end
            else
                local xPlayer = GetPlayer(tonumber(playerId))
                if xPlayer then
                    TriggerClientEvent('hospital:client:Revive', tonumber(playerId))
                end
            end
        end
        TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['allrevive'])
        if discord_webhook["allrevive"].allow and discord_webhook["allrevive"].webhook ~= "" then
            discordLogStaff(tonumber(data.src), tonumber(data.src), discord_webhook["allrevive"].text, 'allrevive')
        end
    end,
    CodemStaffMenuSendPm = function(data)
        local src = data.src
        local target = data.targetID
        local message = data.message
        local xPlayer = GetPlayer(target)
        if xPlayer then
            local pmTable = {
                message = message,
                sender = GetName(src),
            }
            TriggerClientEvent('codem-staffmenu:sendPm', tonumber(target), pmTable)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['sendpm'])
        end
    end,
    CodemStaffMenuAnnouncement = function(data)
        local src = data.src
        local message = data.message
        local announcementTable = {
            message = message,
            sender = GetName(src),
        }
        TriggerClientEvent('codem-staffmenu:sendAnnouncement', -1, announcementTable)
        TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['sendannouncement'])
    end,
    CodemStaffMenuHealQuick = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:healPlayer', src)
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['playerhealed'])
            if discord_webhook["heal"].allow and discord_webhook["heal"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.src), discord_webhook["heal"].text, 'heal')
            end
        end
    end,
    CodemStaffMenuNoclip = function(data)
        local src = data.src
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:toggleNoclip', src)
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['togglenoclip'])
        end
    end,
    CodemStaffMenuClearArea = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            local xTarget = GetPlayerPed(src)
            local coords = GetEntityCoords(xTarget)
            TriggerClientEvent('codem-staffmenu:clearArea', -1, coords, data.distance or 100)
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['cleararea'])
            if discord_webhook["cleararea"].allow and discord_webhook["cleararea"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.src), discord_webhook["cleararea"].text,
                    'cleararea')
            end
        end
    end,
    CodemStaffMenuClearVehicle = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:clearVehicles', src, data.distance)
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['clearvehicle'])
            if discord_webhook["clearvehicle"].allow and discord_webhook["clearvehicle"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.src), discord_webhook["clearvehicle"].text,
                    'clearvehicle')
            end
        end
    end,
    CodemStaffMenuRepairVehicle = function(data)
        local src = tonumber(data.src)
        TriggerClientEvent('codem-staffmenu:repairVehicle', src)
    end,
    CodemStaffMenuTpMarker = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:tpMarker', src)
        end
    end,
    CodemStaffMenuDevLaser = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:devLaser', src)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['devlaser'])
        end
    end,
    CodemStaffMenuGodmode = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:godmode', src)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['togglegodmode'])
        end
    end,
    CodemStaffMenuCopyVector3 = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:copyVector', src)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['copiedvector3'])
        end
    end,
    CodemStaffMenuCopyVector4 = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:copyVector4', src)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['copiedvector4'])
        end
    end,
    CodemStaffMenuCopyVector = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:copyXYZ', src)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['copiedvector'])
        end
    end,
    CodemStaffMenuCopyHeading = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:copyHeading', src)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['copiedheading'])
        end
    end,
    CodemStaffMenuShowCoords = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:toggleCoords', src)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['togglecoords'])
        end
    end,
    CodemStaffMenuQuickTimeMorning = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            setTime(Config.ChangeTime.morning, 00)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['timemorning'])
        end
    end,
    CodemStaffMenuQuickTimeNight = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            setTime(Config.ChangeTime.night, 00)
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['timenight'])
        end
    end,
    CodemStaffMenuQuickWeatherClean = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            SetWeather('CLEAR')
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['weatherclear'])
        end
    end,
    CodemStaffMenuArmor = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:setArmor', src)
        end
    end,
    CodemStaffMenuPlayerName = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:showPlayerName', src)
            if discord_webhook["showplayername"].allow and discord_webhook["showplayername"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.src), discord_webhook["showplayername"].text,
                    'showplayername')
            end
        end
    end,
    CodemStaffMenuInvisible = function(data)
        src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent("codem-staffmenu:setInvinsible", src)
        end
    end,
    CodemStaffMenuGasTank = function(data)
        local src = tonumber(data.src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-staffmenu:setGasTank', src)
        end
    end,
    CodemStaffMenuBan = function(bandata)
        local adminid = tonumber(bandata.src)
        local xPlayer = GetPlayer(tonumber(bandata.data.id))
        local adminIdentifier = GetIdentifier(adminid)
        local adminData = playerServerData[adminIdentifier]
        local checkPermission = CheckPermission(adminData.rankdata.rank, 'ban')
        if not checkPermission and not adminData.rankdata.owner then
            TriggerClientEvent('codem-staff:notification', adminid, Config.BackendLocales['notauthorized'])
            return
        end
        if xPlayer then
            local playerid = tonumber(bandata.data.id)
            local steamid = "Not Found"
            local discord = "Not Found"
            local license = "Not Found"
            local live = "Not Found"
            local xbl = "Not Found"
            local banId = math.random(00000, 99999)
            local C = GetPlayerEndpoint(playerid)
            for _, n in ipairs(GetPlayerIdentifiers(playerid)) do
                if n:match("steam") then
                    steamid = n
                elseif n:match("discord") then
                    discord = n:gsub("discord:", "")
                elseif n:match("license") then
                    license = n
                elseif n:match("live") then
                    live = n
                elseif n:match("xbl") then
                    xbl = n
                end
            end

            banTime = 0
            hour = tonumber(bandata.data.hour)
            min = tonumber(bandata.data.min)

            if hour == 0 and min == 0 then
                banTime = 0
                return
            else
                if hour or min then
                    if hour and hour >= 1 and (not min or min == 0) then
                        banTime = hour * 3600
                    elseif min and min >= 1 and (not hour or hour == 0) then
                        banTime = min * 60
                    elseif hour and hour >= 1 and min and min >= 1 then
                        banTime = hour * 3600 + min * 60
                    end
                end
            end

            if #bandata.data.reason < 1 then
                bandata.data.reason = "No Reason"
            end
            local banlist = {
                ['steam'] = steamid,
                ['discord'] = discord,
                ['license'] = license,
                ['live'] = live,
                ['xbl'] = xbl,
                ['ip'] = C,
                ['name'] = bandata.data.name,
                ['time'] = os.time() + banTime, -- bantime eklenecek
                ['token'] = GetPlayerToken(playerid, 0),
                ['adminname'] = playerServerData[GetIdentifier(tonumber(adminid))].profiledata.name or "Unknown",
                ['openbandate'] = os.date("%d.%m.%Y %I:%M", os.time() + banTime),
                ['bandate'] = os.date("%d.%m.%Y %I:%M"),
                ['BanId'] = banId,
                ['Reason'] = bandata.data.reason
            }
            if banTable[bandata.data.identifier] then
                TriggerClientEvent('codem-staff:notification', bandata.src, Config.BackendLocales['playeralreadybanned'])
                return
            end
            banTable[bandata.data.identifier] = {
                identifier = bandata.data.identifier,
                bandata = banlist
            }

            ExecuteSql(
                'INSERT INTO codem_staff_ban (identifier, bandata) VALUES (:identifier, :bandata)',
                {
                    identifier = bandata.data.identifier,
                    bandata = json.encode(banlist)
                }
            )
            for _, adminID in ipairs(onlineAdminPlayers) do
                local players = GetPlayer(tonumber(adminID))
                if players then
                    TriggerClientEvent('codem-staff:updateBanData', tonumber(adminID), banTable)
                end
            end
            TriggerClientEvent('codem-staff:notification', bandata.src, Config.BackendLocales['playerbanned'])
            local adminidentifier = GetIdentifier(tonumber(bandata.src))
            updateAdminLogData(adminidentifier, 'ban')
            DropPlayer(tonumber(bandata.data.id), bandata.data.reason)
            if discord_webhook["ban"].allow and discord_webhook["ban"].webhook ~= "" then
                discordLogStaff(tonumber(bandata.src), tonumber(bandata.data.id),
                    discord_webhook["ban"].text .. bandata.data.reason, 'ban')
            end
        else
            local banId = math.random(00000, 99999)
            local serverData = playerServerData[bandata.data.identifier]
            if not serverData then
                print('not player')
            end
            banTime = 0
            hour = tonumber(bandata.data.hour)
            min = tonumber(bandata.data.min)
            if hour == 0 and min == 0 then
                banTime = 0
                return
            else
                if hour or min then
                    if hour and hour >= 1 and (not min or min == 0) then
                        banTime = hour * 3600
                    elseif min and min >= 1 and (not hour or hour == 0) then
                        banTime = min * 60
                    elseif hour and hour >= 1 and min and min >= 1 then
                        banTime = hour * 3600 + min * 60
                    end
                end
            end

            if #bandata.data.reason < 1 then
                bandata.data.reason = "No Reason"
            end
            local banlist = {
                ['name'] = bandata.data.name,
                ['steam'] = serverData.profiledata.steam,
                ['discord'] = serverData.profiledata.discord,
                ['license'] = serverData.profiledata.license,
                ['ip'] = serverData.profiledata.ip,
                ['time'] = os.time() + banTime,
                ['token'] = serverData.profiledata.token,
                ['BanId'] = banId,
                ['Reason'] = bandata.data.reason,
                ['adminname'] = playerServerData[GetIdentifier(tonumber(adminid))].profiledata.name or "Unknown",
                ['openbandate'] = os.date("%d.%m.%Y %I:%M", os.time() + banTime),
                ['bandate'] = os.date("%d.%m.%Y %I:%M"),
            }
            if banTable[bandata.data.identifier] then
                TriggerClientEvent('codem-staff:notification', bandata.src, Config.BackendLocales['playeralreadybanned'])
                return
            end
            banTable[bandata.data.identifier] = {
                identifier = bandata.data.identifier,
                bandata = banlist
            }
            ExecuteSql(
                'INSERT INTO codem_staff_ban (identifier, bandata) VALUES (:identifier, :bandata)',
                {
                    identifier = bandata.data.identifier,
                    bandata = json.encode(banlist)
                }
            )
            for _, adminID in ipairs(onlineAdminPlayers) do
                local players = GetPlayer(tonumber(adminID))
                if players then
                    TriggerClientEvent('codem-staff:updateBanData', tonumber(adminID), banTable)
                end
            end
            TriggerClientEvent('codem-staff:notification', bandata.src, Config.BackendLocales['playerbanned'])


            local adminidentifier = GetIdentifier(tonumber(bandata.src))
            updateAdminLogData(adminidentifier, 'ban')
            if discord_webhook["ban"].allow and discord_webhook["ban"].webhook ~= "" then
                discordLogStaff(tonumber(bandata.src), tonumber(bandata.data.id),
                    discord_webhook["ban"].text .. bandata.data.reason, 'ban')
            end
        end
    end,
    CodemStaffMenuUnBan = function(unbandata)
        local src = source
        local identifier = GetIdentifier(src)
        local adminData = playerServerData[identifier]
        local checkPermission = CheckPermission(adminData.rankdata.rank, 'unban')
        if not checkPermission and not adminData.rankdata.owner then
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['notauthorized'])
            return
        end
        if banTable[unbandata.data.identifier] then
            banTable[unbandata.data.identifier] = nil
            ExecuteSql(
                'DELETE FROM codem_staff_ban WHERE identifier = :identifier',
                {
                    identifier = unbandata.data.identifier
                }
            )
            TriggerClientEvent('codem-staff:updateBanData', tonumber(unbandata.src), banTable)
            TriggerClientEvent('codem-staff:notification', tonumber(unbandata.src),
                Config.BackendLocales['playerunbanned'])
        end
    end,
    CodemStaffMenuBanPlayer = function(data)
        print(json.encode(data))
        local src = tonumber(data.src)
        local zTarget = tonumber(data.targetID)
        local xPlayer = GetPlayer(src)
        local zPlayer = GetPlayer(zTarget)
        if tonumber(data.src) == tonumber(data.targetID) then
            TriggerClientEvent('codem-staff:notification', data.src, Config.BackendLocales['selfban'])
            return
        end
        if xPlayer and zPlayer then
            local identifier = GetIdentifier(zTarget)
            local adminidentifier = GetIdentifier(src)
            local serverdata = playerServerData[identifier]
            if not serverdata then
                TriggerClientEvent('codem-staff:notification', src,
                    string.format(Config.BackendLocales['playerdatanotfound'], identifier))
                return
            end
            local steamid = "Not Found"
            local discord = "Not Found"
            local license = "Not Found"
            local live = "Not Found"
            local xbl = "Not Found"
            local banId = math.random(00000, 99999)
            local C = GetPlayerEndpoint(zTarget)
            local adminname = playerServerData[adminidentifier].profiledata.name or "Unknown"
            for _, n in ipairs(GetPlayerIdentifiers(zTarget)) do
                if n:match("steam") then
                    steamid = n
                elseif n:match("discord") then
                    discord = n:gsub("discord:", "")
                elseif n:match("license") then
                    license = n
                elseif n:match("live") then
                    live = n
                elseif n:match("xbl") then
                    xbl = n
                end
            end
            banTime = 0
            hour = tonumber(data.hour)
            min = tonumber(data.min)

            if data.permaban then
                banTime = 999999999
            else
                if hour == 0 and min == 0 then
                    banTime = 0
                    return
                else
                    if hour or min then
                        if hour and hour >= 1 and (not min or min == 0) then
                            banTime = hour * 3600
                        elseif min and min >= 1 and (not hour or hour == 0) then
                            banTime = min * 60
                        elseif hour and hour >= 1 and min and min >= 1 then
                            banTime = hour * 3600 + min * 60
                        end
                    end
                end
            end

            if #data.reason < 1 then
                data.reason = "No Reason"
            end
            local banlist = {
                ['steam'] = steamid,
                ['discord'] = discord,
                ['license'] = license,
                ['live'] = live,
                ['xbl'] = xbl,
                ['ip'] = C,
                ['name'] = GetName(zTarget),
                ['time'] = os.time() + banTime,
                ['token'] = GetPlayerToken(zTarget, 0),
                ['adminname'] = adminname or "Unknown",
                ['bandate'] = os.date("%d.%m.%Y %I:%M"),
                ['openbandate'] = os.date("%d.%m.%Y %I:%M", os.time() + banTime),
                ['BanId'] = banId,
                ['Reason'] = data.reason or "No Reason"
            }
            if banTable[identifier] then
                TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['playeralreadybanned'])
                return
            end
            banTable[identifier] = {
                identifier = identifier,
                bandata = banlist
            }
            ExecuteSql(
                'INSERT INTO codem_staff_ban (identifier, bandata) VALUES (:identifier, :bandata)',
                {
                    identifier = identifier,
                    bandata = json.encode(banlist)
                }
            )
            local historydata = serverdata.historydata
            local history = {
                reason = data.reason or "No Reason",
                admin = adminname,
                avatar = serverdata.profiledata.avatar or Config.ExampleProfilePicture,
                time = os.date("%m.%d.%Y %I:%M")
            }
            if data.permaban then
                if type(historydata) == "table" and not historydata.permaban then
                    historydata.permaban = {}
                end
                table.insert(historydata.permaban, history)
            else
                if type(historydata) == "table" and not historydata.ban then
                    historydata.ban = {}
                end
                table.insert(historydata.ban, history)
            end
            serverdata.historydata = historydata
            ExecuteSql(
                'UPDATE codem_staff_playersdata SET historydata = :historydata WHERE identifier = :identifier',
                {
                    identifier = identifier,
                    historydata = json.encode(serverdata.historydata)
                }
            )
            DropPlayer(zTarget, data.reason)
            TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['playerbanned'])
            Citizen.Wait(100)
            if discord_webhook["ban"].allow and discord_webhook["ban"].webhook ~= "" then
                discordLogStaff(tonumber(data.src), tonumber(data.targetID),
                    discord_webhook["ban"].text .. data.reason, 'ban')
            end
            TriggerClientEvent('codem-staffmenu:updateBanKickdata', src,
                { historydata = serverdata.historydata, playerid = zTarget })
            if data.permaban then
                updateAdminLogData(adminidentifier, 'perma')
            else
                updateAdminLogData(adminidentifier, 'ban')
            end
            for _, adminID in ipairs(onlineAdminPlayers) do
                local players = GetPlayer(tonumber(adminID))
                if players then
                    TriggerClientEvent('codem-staff:updateBanData', tonumber(adminID), banTable)
                end
            end
        end
    end
}

RegisterServerEvent('codem-staffmenu:server:setWeather', function(data)
    local src = source
    local identifier = GetIdentifier(src)
    local adminData = playerServerData[identifier]
    if Config.StaffDuty then
        if not staffDuty[src] then
            return TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['openduty'])
        end
    end
    if not adminData then
        TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['admindatanotfound'])
        return
    end

    local checkPermission = CheckPermission(adminData.rankdata.rank, 'weather')
    if not checkPermission and not adminData.rankdata.owner then
        TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['notauthorized'])
        return
    end

    SetWeather(data)
    TriggerClientEvent('codem-staff:notification', src, string.format(Config.BackendLocales['weatherchanged'], data))
end)

RegisterServerEvent('codem-staffmenu:server:setTime', function(data)
    local src = source
    local identifier = GetIdentifier(src)
    local adminData = playerServerData[identifier]
    if Config.StaffDuty then
        if not staffDuty[src] then
            return TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['openduty'])
        end
    end
    if not adminData then
        TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['admindatanotfound'])
        return
    end

    local checkPermission = CheckPermission(adminData.rankdata.rank, 'servertime')

    if not checkPermission and not adminData.rankdata.owner then
        TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['notauthorized'])
        return
    end
    setTime(data.hours, data.minutes)
    TriggerClientEvent('codem-staff:notification', src,
        string.format(Config.BackendLocales['timechanged'], data.hours, data.minutes))
end)

RegisterServerEvent('codem-staffmenu:server:setFreeze', function(data)
    local src = source
    local src = source
    local identifier = GetIdentifier(src)
    local adminData = playerServerData[identifier]
    if Config.StaffDuty then
        if not staffDuty[src] then
            return TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['openduty'])
        end
    end
    if not adminData then
        TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['admindatanotfound'])
        return
    end

    local checkPermission = CheckPermission(adminData.rankdata.rank, 'servertime')
    local checkPermissionWeather = CheckPermission(adminData.rankdata.rank, 'weather')
    if (not checkPermission and not checkPermissionWeather) and not adminData.rankdata.owner then
        TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['notauthorized'])
        return
    end
    setTime(data.hours, data.minutes)
    Wait(300)
    freezeTime()
    TriggerClientEvent('codem-staff:notification', src, Config.BackendLocales['timefreeze'])
end)

RegisterServerEvent('codem-staffmenu:server:staffDutyStatus', function(value)
    local src = source
    if value then
        staffDuty[src] = true
        TriggerClientEvent('codem-staffmenu:adminClothes', src, true)
    else
        staffDuty[src] = false
        TriggerClientEvent('codem-staffmenu:adminClothes', src, false)
    end
end)


function GetTimeandWeather()
    if GetResourceState("qb-weathersync") == "started" then
        local fulltime = getTime()
        local weather = getWeather()
        local freeze = getFreeze()

        local data = {
            time = fulltime,
            weather = weather,
            freeze = freeze,
            AvailableWeatherTypes = Config.AvailableWeatherTypes
        }
        return data
    elseif GetResourceState("cd_easytime") == "started" then
        local fulltime = getTime()
        local weather = getWeather()
        local freeze = getFreeze()

        local data = {
            time = fulltime,
            weather = weather,
            freeze = freeze,
            AvailableWeatherTypes = Config.AvailableWeatherTypes
        }
        return data
    else
        print("weather script is not started")
        return false
    end
end

function getTime()
    if GetResourceState("qb-weathersync") == "started" then
        local hour, min = exports["qb-weathersync"]:getTime()
        local fulltime = hour .. ":" .. min
        return fulltime
    elseif GetResourceState("cd_easytime") == "started" then
        local hour = exports["cd_easytime"]:GetWeather().hours
        local min = exports["cd_easytime"]:GetWeather().mins
        local fulltime = hour .. ":" .. min
        return fulltime
    else
        print("weather script is not started")
        return false
    end
end

function getWeather()
    if GetResourceState("qb-weathersync") == "started" then
        local weather = exports["qb-weathersync"]:getWeatherState()
        return weather
    elseif GetResourceState("cd_easytime") == "started" then
        local weather = exports["cd_easytime"]:GetWeather().weather
        return weather
    else
        print("weather script is not started")
        return false
    end
end

function getFreeze()
    if GetResourceState("qb-weathersync") == "started" then
        local freeze = exports["qb-weathersync"]:getTimeFreezeState()
        return freeze
    elseif GetResourceState("cd_easytime") == "started" then
        local freeze = exports["cd_easytime"]:GetWeather().freeze
    else
        print("weather script is not started")
        return false
    end
end

function SetWeather(value)
    if GetResourceState("qb-weathersync") == "started" then
        exports["qb-weathersync"]:setWeather(value)
    else
        print("weather script is not started")
    end
end

function setTime(hour, min)
    if GetResourceState("qb-weathersync") == "started" then
        exports["qb-weathersync"]:setTime(tonumber(hour), tonumber(min))
    else
        print("weather script is not started")
    end
end

function freezeTime()
    if GetResourceState("qb-weathersync") == "started" then
        exports["qb-weathersync"]:setTimeFreeze()
    else
        print("weather script is not started")
    end
end

function GetPlayerBlackMoney(source)
    local Player = GetPlayer(source)
    if Player then
        local inventory = GetPlayerInventory(source)
        local totalWorth = 0 
        for k, v in pairs(inventory) do
            if v.name == Config.BlackMoney["item"] or v.name == 'markedbills' then
                if Config.BlackMoney["itemInfo"] then
                    if not v.info then
                        return 0
                    end
                    local infoworth = v.info.worth or 0
                    local count = v.amount or v.count
                    local worth = infoworth * count
                    totalWorth = totalWorth + worth
                else
                    count = v.amount or v.count
                    totalWorth = totalWorth + count
                end 
            end
        end
        return totalWorth 
    end
    return 0
end

function AddBlackMoney(source, amount)
    amount = tonumber(amount) or 0
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            addInventoryItem(source, Config.BlackMoney["item"], amount)
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if Config.BlackMoney["itemInfo"] then
                local info = {
                    worth = amount
                }
                addInventoryItem(source, Config.BlackMoney["item"], 1, false, info)
            else
                addInventoryItem(source, Config.BlackMoney["item"], amount)
            end
        end
    end
end

function RemoveBlackMoney(source, amount)
    amount = tonumber(amount) or 0
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            removeInventoryItem(source, Config.BlackMoney["item"], amount)
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if Config.BlackMoney["itemInfo"] then
                local inventory = GetPlayerInventory(source)
                local totalWorth = 0
                local markedBillsToRemove = {}
                for k, v in pairs(inventory) do
                    if v.name == Config.BlackMoney["item"] then
                        local infoworth = v.info.worth or 0
                        local count = v.amount or v.count
                        local worth = infoworth * count
                        totalWorth = totalWorth + worth
                        table.insert(markedBillsToRemove, k)
                    end
                end
                if totalWorth >= amount then
                    for _, index in ipairs(markedBillsToRemove) do
                        removeInventoryItem(source, Config.BlackMoney["item"], inventory[index].amount)
                    end
                    AddBlackMoney(source, totalWorth - amount)
                end
            else
                removeInventoryItem(source, Config.BlackMoney["item"], amount)
            end
        end
    end
end

function addVipCoin(playerid, amount)
    if Config.CodemVipSystem then
        if GetResourceState("m-vipsystem") == "started" then
            exports['m-vipsystem']:addPlayerCoin(playerid, amount)
            return true
        else
            print("vip system is not started")
            return false
        end
    else
        print("vip system is not started")
        return false
    end
end

function removeVipCoin(playerid, amount)
    if Config.CodemVipSystem then
        if GetResourceState("m-vipsystem") == "started" then
            exports['m-vipsystem']:removePlayerCoin(tonumber(playerid), tonumber(amount))
            return true
        else
            print("vip system is not started")
            return false
        end
    else
        print("vip system is not started")
        return false
    end
end

function GetPlayerCoin(source)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        if Config.CodemVipSystem then
            if GetResourceState("m-vipsystem") == "started" then
                local result = exports["m-vipsystem"]:getPlayerVipMoney(source)
                return result or 0
            end
        else
            print("vip system is not started")
            return 0
        end
    end
end

function GetPlayerInventory(source)
    local data = {}
    local Player = GetPlayer(source)
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        for _, v in pairs(Player.getInventory()) do
            v.count = v.count or v.amount
            if v and tonumber(v.count) > 0 then
                local formattedData = v
                formattedData.name = string.lower(v.name)
                formattedData.label = v.label
                formattedData.amount = v.count
                formattedData.image = v.image or (string.lower(v.name) .. '.png')
                table.insert(data, formattedData)
            end
        end
    else
        for _, v in pairs(Player.PlayerData.items) do
            if v then
                local amount = v.count or v.amount
                if tonumber(amount) > 0 then
                    local formattedData = v
                    formattedData.name = string.lower(v.name)
                    formattedData.label = v.label
                    formattedData.amount = amount
                    formattedData.image = v.image or (string.lower(v.name) .. '.png')
                    table.insert(data, formattedData)
                end
            end
        end
    end
    return data
end

function OpenPlayerInventory(src, targetID)
    local Player = GetPlayer(src)
    local xTarget = GetPlayer(targetID)
    if Player and xTarget then
        TriggerClientEvent("codem-adminmenu:openPlayerInventory", src, targetID)
    end
end

function addInventoryItem(src, item, amount, slot, info)
    local Player = GetPlayer(src)
    if Player then
        if Config.Inventory == "qb_inventory" then
            Player.Functions.AddItem(item, amount, slot, info)
        elseif Config.Inventory == "esx_inventory" then
            Player.addInventoryItem(item, amount)
        elseif Config.Inventory == "ox_inventory" then
            exports.ox_inventory:AddItem(src, item, amount)
        elseif Config.Inventory == "codem-inventory" then
            exports["codem-inventory"]:AddItem(src, item, amount, slot, info)
        elseif Config.Inventory == "qs_inventory" then
            exports['qs-inventory']:AddItem(src, item, count)
        end
    end
end

function removeInventoryItem(src, item, amount)
    local Player = GetPlayer(src)
    if Player then
        if Config.Inventory == "qb_inventory" then
            Player.Functions.RemoveItem(item, amount)
        elseif Config.Inventory == "esx_inventory" then
            Player.removeInventoryItem(item, amount)
        elseif Config.Inventory == "ox_inventory" then
            exports.ox_inventory:RemoveItem(src, item, amount)
        elseif Config.Inventory == "codem-inventory" then
            exports["codem-inventory"]:RemoveItem(src, item, amount)
        elseif Config.Inventory == "qs_inventory" then
            exports['qs-inventory']:RemoveItem(src, item, amount)
        end
    end
end

function clearInventory(src)
    local Player = GetPlayer(src)
    if Player then
        if Config.Inventory == "codem-inventory" then
            exports["codem-inventory"]:ClearInventory(src)
        elseif Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:ClearInventory(src)
        elseif Config.Inventory == 'qb_inventory' then
            exports['qb-inventory']:ClearInventory(src)
        elseif Config.Inventory == 'esx_inventory' then
            TriggerEvent('esx:playerInventoryCleared', src)
        elseif Config.Inventory == 'qs_inventory' then
            local saveItems = {
                'id_card', -- Add here the items that you do NOT want to be deleted
                'phone',
            }
            exports['qs-inventory']:ClearInventory(src, saveItems)
        end
    end
end

function GetPlayerVehicles(source)
    local data = {}
    local playerIdentifer = GetIdentifier(source)
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        local result = ExecuteSql("SELECT vehicle, plate FROM owned_vehicles WHERE owner = '" .. playerIdentifer .. "'")
        if result ~= nil then
            for _, v in pairs(result) do
                local success, vehicleData = pcall(json.decode, v.vehicle)
                if success then
                    local formattedvehicleData = v
                    formattedvehicleData.vehicle = vehicleData.model
                    formattedvehicleData.plate = v.plate
                    table.insert(data, formattedvehicleData)
                end
            end
        end
    else
        local result = ExecuteSql("SELECT vehicle, plate FROM player_vehicles WHERE citizenid = '" ..
            playerIdentifer .. "'")
        if result ~= nil then
            for _, v in pairs(result) do
                local formattedvehicleData = v
                formattedvehicleData.vehicle = string.lower(v.vehicle)
                formattedvehicleData.plate = v.plate
                table.insert(data, formattedvehicleData)
            end
        end
    end
    return data
end

function GetJob(source)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            return Player.getJob().name
        else
            return Player.PlayerData.job.name
        end
    end
    return false
end

function GetJobGrade(source)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            return Player.getJob().grade_label
        else
            return Player.PlayerData.job.grade.name
        end
    end
    return false
end

function GetJobIcon(jobname)
    local job = Config.JobIcon[jobname]
    if job then
        return job.icon
    end
    return "citizen.svg"
end

function RemoveMoney(source, type, value)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            if type == 'bank' then
                Player.removeAccountMoney('bank', value)
            end
            if type == 'cash' then
                Player.removeMoney(value)
            end
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if type == 'bank' then
                Player.Functions.RemoveMoney('bank', value)
            end
            if type == 'cash' then
                Player.Functions.RemoveMoney('cash', value)
            end
        end
    end
end

function AddMoney(source, type, value)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            if type == 'bank' then
                Player.addAccountMoney('bank', value)
            end
            if type == 'cash' then
                Player.addMoney(value)
            end
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if type == 'bank' then
                Player.Functions.AddMoney('bank', value)
            end
            if type == 'cash' then
                Player.Functions.AddMoney('cash', value)
            end
        end
    end
end

function GetPlayerMoney(source, value)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            if value == 'bank' then
                return Player.getAccount('bank').money
            end
            if value == 'cash' then
                return Player.getMoney()
            end
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if value == 'bank' then
                return Player.PlayerData.money['bank']
            end
            if value == 'cash' then
                return Player.PlayerData.money['cash']
            end
        end
    end
end
