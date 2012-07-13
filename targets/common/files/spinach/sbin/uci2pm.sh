#!/bin/ash
#
# Replace variables in /etc/plantmesh.conf with current uci config
#  optionally supply filepath for plantmesh.conf as first arg

replace_var_with_value() {
	local _VAR="${1}"
	local _VALUE="${2}"

	if [ ! -z "${3}" ]; then
		local _PM_CONF_FILE="${3}"
	else
		local _PM_CONF_FILE="/etc/plantmesh.conf"
	fi

	if [ ! -w "${_PM_CONF_FILE}" ]; then
		echo "Warning: ${_PM_CONF_FILE} does not appear to be a writable file, not updated"
		return
	fi

	# if no value was found in uci, delete from plantmesh.conf
	if [ "${_VALUE}z" == "z" ]; then
		sed -i -e "/${_VAR}/d" "${_PM_CONF_FILE}"
		return
	fi

	if ! grep "${_VAR}" "${_PM_CONF_FILE}" &> /dev/null; then
		echo ${_VAR}=\"${_VALUE}\" >> "${_PM_CONF_FILE}"
	else
		sed -i -e "s/\(${_VAR}\)=\(.*\)$/\1=\"${_VALUE}\"/" "${_PM_CONF_FILE}"
	fi
}

# Handle mesh config in uci
local _DEVICE=`uci get wireless.mesh0.device`

if [ -z "${_DEVICE}" ]; then
	echo "Warning: Unable to determine device for mesh0"
else
	replace_var_with_value PM_MESH_CHANNEL `uci get wireless.${_DEVICE}.channel` ${1}
	replace_var_with_value PM_MESH_HWMODE `uci get wireless.${_DEVICE}.hwmode` ${1}
	replace_var_with_value PM_MESH_HTMODE `uci get wireless.${_DEVICE}.htmode` ${1}
fi
replace_var_with_value PM_MESHID `uci get wireless.mesh0.mesh_id` ${1}
replace_var_with_value PM_MESHKEY `uci get wireless.mesh0.mesh_key` ${1}


# Handle AP config in uci
local _DEVICE=`uci get wireless.ap0.device`

if [ -z "${_DEVICE}" ]; then
	echo "Warning: Unable to determine device for ap0"
else
	replace_var_with_value PM_AP_CHANNEL `uci get wireless.${_DEVICE}.channel` ${1}
	replace_var_with_value PM_AP_HWMODE `uci get wireless.${_DEVICE}.hwmode` ${1}
	replace_var_with_value PM_AP_HTMODE `uci get wireless.${_DEVICE}.htmode` ${1}
fi
replace_var_with_value PM_SSID `uci get wireless.ap0.ssid` ${1}
replace_var_with_value PM_KEY `uci get wireless.ap0.key` ${1}
