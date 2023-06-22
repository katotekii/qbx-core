---@deprecated
QBCore.Commands = {}

function QBCore.Commands.Add(name, help, arguments, argsrequired, callback, permission)
    print(string.format("/!\\ Not an Error /!\\ | %s invoked deprecated Commands function. Please use Ox_lib's addCommand instead.", GetInvokingResource()))
    local properties = {
        help = help,
        restricted = ((permission and permission ~= "user") and 'qbox.'..permission) or false,
        params = {}
    }
    for i=1, #arguments do
        local argument = arguments[i]
        properties.params[i] = {
            name = argument.name,
            help = argument.help,
            type = argument.type or nil,
            optional = (not argsrequired) or (argument?.optional == true)
        }
    end
    lib.addCommand(name, properties, function(source, args, raw)
        local _args = {}
        for _,v in pairs(args) do
            _args[#_args+1] = v
        end
        callback(source, _args, raw)
    end)
end
--

-- Teleport

lib.addCommand('tp', {
    help = Lang:t("command.tp.help"),
    params = {
        { name = Lang:t("command.tp.params.x.name"), help = Lang:t("command.tp.params.x.help"), optional = false},
        { name = Lang:t("command.tp.params.y.name"), help = Lang:t("command.tp.params.y.help"), optional = true },
        { name = Lang:t("command.tp.params.z.name"), help = Lang:t("command.tp.params.z.help"), optional = true }
    },
    restricted = "qbox.admin"
}, function(source, args)
    if args[Lang:t("command.tp.params.x.name")] and not args[Lang:t("command.tp.params.y.name")] and not args[3] then
        if tonumber(args[1]) then
            local target = GetPlayerPed(tonumber(args[Lang:t("command.tp.params.x.name")]) --[[@as number]])
            if target ~= 0 then
                local coords = GetEntityCoords(target)
                TriggerClientEvent('QBCore:Command:TeleportToPlayer', source, coords)
            else
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
            end
        else
            local location = QBShared.Locations[args[Lang:t("command.tp.params.x.name")]]
            if location then
                TriggerClientEvent('QBCore:Command:TeleportToCoords', source, location.x, location.y, location.z, location.w)
            else
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.location_not_exist'), 'error')
            end
        end
    else
        if args[Lang:t("command.tp.params.x.name")] and args[Lang:t("command.tp.params.y.name")] and args[Lang:t("command.tp.params.z.name")] then
            local x = tonumber((args[Lang:t("command.tp.params.x.name")]:gsub(",",""))) + .0
            local y = tonumber((args[Lang:t("command.tp.params.y.name")]:gsub(",",""))) + .0
            local z = tonumber((args[Lang:t("command.tp.params.z.name")]:gsub(",",""))) + .0
            if x ~= 0 and y ~= 0 and z ~= 0 then
                TriggerClientEvent('QBCore:Command:TeleportToCoords', source, x, y, z)
            else
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.wrong_format'), 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.missing_args'), 'error')
        end
    end
end)


lib.addCommand('tpm', {
    help = Lang:t("command.tpm.help"),
    restricted = "qbox.admin"
}, function(source, _)
    TriggerClientEvent('QBCore:Command:GoToMarker', source)
end)

lib.addCommand('togglepvp', {
    help = Lang:t("command.togglepvp.help"),
    restricted = "qbox.god"
}, function(_, _)
    QBConfig.Server.PVP = not QBConfig.Server.PVP
    TriggerClientEvent('QBCore:Client:PvpHasToggled', -1, QBConfig.Server.PVP)
end)

-- Permissions

lib.addCommand('addpermission', {
    help = Lang:t("command.addpermission.help"),
    params = {
        {name = Lang:t("command.addpermission.params.id.name"), help = Lang:t("command.addpermission.params.id.help")},
        {name = Lang:t("command.addpermission.params.permission.name"), help = Lang:t("command.addpermission.params.permission.help")}
    },
    restricted = "qbox.god"
}, function(source, args)
    local player = QBCore.Functions.GetPlayer(tonumber(args[Lang:t("command.addpermission.params.id.name")]))
    local permission = tostring(args[Lang:t("command.addpermission.params.permission.name")])
    if not player then
      TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
      return
    end
    QBCore.Functions.AddPermission(player.PlayerData.source, permission)
end)

lib.addCommand('removepermission', {
    help = Lang:t("command.removepermission.help"),
    params = {
        { name = Lang:t("command.removepermission.params.id.name"), help = Lang:t("command.removepermission.params.id.help") },
        { name = Lang:t("command.removepermission.params.permission.name"), help = Lang:t("command.removepermission.params.permission.help") }
    },
    restricted = "qbox.god"
}, function(source, args)
    local player = QBCore.Functions.GetPlayer(tonumber(args[Lang:t("command.removepermission.params.id.name")]))
    local permission = tostring(args[Lang:t("command.removepermission.params.permission.name")])
    if not player then
       TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
    QBCore.Functions.RemovePermission(player.PlayerData.source, permission)
end)

-- Open & Close Server

lib.addCommand('openserver', {
    help = Lang:t("command.openserver.help"),
    restricted = "qbox.god"
}, function(source, _)
    if not QBCore.Config.Server.Closed then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.server_already_open'), 'error')
        return
    end
    if QBCore.Functions.HasPermission(source, 'admin') then
        QBCore.Config.Server.Closed = false
        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.server_opened'), 'success')
    else
        KickWithReason(source, Lang:t("error.no_permission"), nil, nil)
    end
end)

lib.addCommand('closeserver', {
    help = Lang:t("command.openserver.help"),
    params = {
        { name = Lang:t("command.closeserver.params.reason.name"), help = Lang:t("command.closeserver.params.reason.help")}
    },
    restricted = "qbox.god"
}, function(source, args)
    if QBCore.Config.Server.Closed then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.server_already_closed'), 'error')
        return
    end
    if QBCore.Functions.HasPermission(source, 'admin') then
        local reason = args[1] or 'No reason specified'
        QBCore.Config.Server.Closed = true
        QBCore.Config.Server.ClosedReason = reason
        for k in pairs(QBCore.Players) do
            if not QBCore.Functions.HasPermission(k, QBCore.Config.Server.WhitelistPermission) then
                KickWithReason(k, reason, nil, nil)
            end
        end
        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.server_closed'), 'success')
    else
        KickWithReason(source, Lang:t("error.no_permission"), nil, nil)
    end
end)

-- Vehicle

lib.addCommand('car', {
    help = Lang:t("command.car.help"),
    params = {
        { name = Lang:t("command.car.params.model.name"), help = Lang:t("command.car.params.model.help") }
    },
    restricted = "qbox.admin"
}, function(source, args)
    if not args then return end
    QBCore.Functions.CreateVehicle(source, args.model, nil, true)
end)

lib.addCommand('dv', {
    help = Lang:t("command.dv.help"),
    restricted = "qbox.admin"
}, function(source, _)
    TriggerClientEvent('QBCore:Command:DeleteVehicle', source)
end)

-- Money

lib.addCommand('givemoney', {
    help = Lang:t("command.givemoney.help"),
    params = {
        { name = Lang:t("command.givemoney.params.id.name"), help = Lang:t("command.givemoney.params.id.help") },
        { name = Lang:t("command.givemoney.params.moneytype.name"), help = Lang:t("command.givemoney.params.moneytype.help") },
        { name = Lang:t("command.givemoney.params.amount.name"), help = Lang:t("command.givemoney.params.amount.help") }
    },
    restricted = "qbox.god"
}, function(source, args)
    local player = QBCore.Functions.GetPlayer(tonumber(args[Lang:t("command.givemoney.params.id.name")]))
    if not player then
       TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
    player.Functions.AddMoney(tostring(args[Lang:t("command.givemoney.params.moneytype.name")]), tonumber(args[Lang:t("command.givemoney.params.amount.name")]))
end)

lib.addCommand('setmoney', {
    help = Lang:t("command.setmoney.help"),
    params = {
        { name = Lang:t("command.setmoney.params.id.name"), help = Lang:t("command.setmoney.params.id.help") },
        { name = Lang:t("command.setmoney.params.moneytype.name"), help = Lang:t("command.setmoney.params.moneytype.help") },
        { name = Lang:t("command.setmoney.params.amount.name"), help = Lang:t("command.setmoney.params.amount.help") }
    },
    restricted = "qbox.god"
}, function(source, args)
    local player = QBCore.Functions.GetPlayer(tonumber(args[Lang:t("command.setmoney.params.id.name")]))
    if not player then
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
    player.Functions.SetMoney(tostring(args[Lang:t("command.setmoney.params.moneytype.name")]), tonumber(args[Lang:t("command.setmoney.params.amount.name")]))
end)

-- Job
lib.addCommand('job', {
    help = Lang:t("command.job.help"),
    restricted = "qbox.user"
}, function(source, _)
    local PlayerJob = QBCore.Functions.GetPlayer(source).PlayerData.job
    TriggerClientEvent('QBCore:Notify', source, Lang:t('info.job_info', {value = PlayerJob.label, value2 = PlayerJob.grade.name, value3 = PlayerJob.onduty}))
end)

lib.addCommand('setjob', {
    help = Lang:t("command.setjob.help"),
    params = {
        { name = Lang:t("command.setjob.params.id.name"), help = Lang:t("command.setjob.params.id.help") },
        { name = Lang:t("command.setjob.params.job.name"), help = Lang:t("command.setjob.params.job.help") },
        { name = Lang:t("command.setjob.params.grade.name"), help = Lang:t("command.setjob.params.grade.help"), optional = true }
    },
    restricted = "qbox.god"
}, function(source, args)
    local player = QBCore.Functions.GetPlayer(tonumber(args[Lang:t("command.setjob.params.id.name")]))
    if not player then
      TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
    if args[Lang:t("command.setjob.params.grade.name")] then
      player.Functions.SetJob(tostring(args[Lang:t("command.setjob.params.job.name")]), tonumber(args[Lang:t("command.setjob.params.grade.name")]))
    else
      player.Functions.SetJob(tostring(args[Lang:t("command.setjob.params.job.name")]), 0)
    end
end)

-- Gang

lib.addCommand('gang', {
    help = Lang:t("command.gang.help"),
    restricted = "qbox.user"
}, function(source, _)
    local PlayerGang = QBCore.Functions.GetPlayer(source).PlayerData.gang
    TriggerClientEvent('QBCore:Notify', source, Lang:t('info.gang_info', {value = PlayerGang.label, value2 = PlayerGang.grade.name}))
end)

lib.addCommand('setgang', {
    help = Lang:t("command.setgang.help"),
    params = {
        { name = Lang:t("command.setgang.params.id.name"), help = Lang:t("command.setgang.params.id.help") },
        { name = Lang:t("command.setgang.params.gang.name"), help = Lang:t("command.setgang.params.gang.help") },
        { name = Lang:t("command.setgang.params.grade.name"), help = Lang:t("command.setgang.params.grade.help"), optional = true }
    },
    restricted = "qbox.god"
}, function(source, args)
    local player = QBCore.Functions.GetPlayer(tonumber(args[Lang:t("command.setgang.params.id.name")]))
    if not player then
       TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end  
    if args[Lang:t("command.setgang.params.grade.name")] then
      player.Functions.SetGang(tostring(args[Lang:t("command.setgang.params.gang.name")]), tonumber(args[Lang:t("command.setgang.params.grade.name")]))
    else
      player.Functions.SetGang(tostring(args[Lang:t("command.setgang.params.gang.name")]), 0)
    end
end)

-- Out of Character Chat

lib.addCommand('ooc', {
    help = Lang:t("command.ooc.help"),
    restricted = "qbox.user"
}, function(source, args)
    local message = table.concat(args, ' ')
    local Players = GetPlayers()
    local Player = QBCore.Functions.GetPlayer(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    for _, v in pairs(Players) do
        if v == source then
            TriggerClientEvent('chat:addMessage', v --[[@as Source]], {
                color = { 0, 0, 255},
                multiline = true,
                args = {('OOC | %s'):format(GetPlayerName(source)), message}
            })
        elseif #(playerCoords - GetEntityCoords(GetPlayerPed(v))) < 20.0 then
            TriggerClientEvent('chat:addMessage', v --[[@as Source]], {
                color = { 0, 0, 255},
                multiline = true,
                args = {('OOC | %s'):format(GetPlayerName(source)), message}
            })
        elseif QBCore.Functions.HasPermission(v --[[@as Source]], 'admin') then
            if QBCore.Functions.IsOptin(v --[[@as Source]]) then
                TriggerClientEvent('chat:addMessage', v --[[@as Source]], {
                    color = { 0, 0, 255},
                    multiline = true,
                    args = {('Proximity OOC | %s'):format(GetPlayerName(source)), message}
                })
                TriggerEvent('qb-log:server:CreateLog', 'ooc', 'OOC', 'white', '**' .. GetPlayerName(source) .. '** (CitizenID: ' .. Player.PlayerData.citizenid .. ' | ID: ' .. source .. ') **Message:** ' .. message, false)
            end
        end
    end
end)


-- Me command

lib.addCommand('me', {
    help = Lang:t("command.me.help"),
    params = {
        { name = Lang:t("command.me.params.message.name"), help = Lang:t("command.me.params.message.help") }
    },
    restricted = "qbox.user"
}, function(source, args)
    if #args < 1 then TriggerClientEvent('QBCore:Notify', source, Lang:t('error.missing_args2'), 'error') return end
    local msg = table.concat(args, ' '):gsub('[~<].-[>~]', '')
    local playerState = Player(source).state
    playerState:set('me', msg, true)

    -- We have to reset the playerState since the state does not get replicated on StateBagHandler if the value is the same as the previous one --
    playerState:set('me', nil, true)
end)
