--- A simple wrapper around SendNUIMessage that you can use to
--- dispatch actions to the React frame.
---
---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function SendReactMessage(action, data)
  SendNUIMessage({
		type = action, 
		data
	})
end

RegisterNUICallback("closeBox", function(_, cb)
 	SetNuiFocus(false, false)
  cb({})
end)

