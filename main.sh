_FuncBasic() {
	set -uC
	set -o pipefail
}

_ValidateParamsNum() (
	_FuncBasic

	MsgTmpl_FuncParamsNum_Error='Error. You should specify exactly %s parameter(s). You have specified %s parameter(s).\n'

	RequiredParamsNum=$1
	ActualParamsNum=$2

	[ $ActualParamsNum -eq $RequiredParamsNum ] ||
	{
		>&2 printf "${MsgTmpl_FuncParamsNum_Error}" $RequiredParamsNum $ActualParamsNum
		exit 1
	}
)

Clone() (
	_FuncBasic &&
	Dir="$1" &&
	Url="$2" &&
	mkdir -p "${Dir}" &&
	cd "${Dir}" &&
	{
		[ -n "$( find . -mindepth 1 )" ] ||
		{
			git clone --depth 1 "${Url}" . &&
			git config core.fileMode false
		}
	}
)

Main() (
	_ValidateParamsNum 3 $# || exit $?

	_FuncBasic &&
	CoreDir="$1" &&
	TextDir="$2" &&
	SysDir="$3" &&
	UrlBase='https://victor-yarema@github.com/victor-yarema/' &&

	{
		git --version > /dev/null ||
		sudo apt install git
	} &&

	Clone "${CoreDir}" "${UrlBase}ShToolsCore" &&
	Clone "${TextDir}" "${UrlBase}ShToolsText" &&

	. "${CoreDir}/__LoadFuncs.noload.sh" "${CoreDir}" "${CoreDir}" '' &&
	. "${CoreDir}/__LoadFuncs.noload.sh" "${CoreDir}" "${TextDir}" '' &&

	mkdir -p "${SysDir}" &&

	CoreInitFile="${SysDir}/ShToolsCore" &&
	AppendText "${CoreInitFile}" '# Main' \
"ShToolsCoreDir='${CoreDir}'
"'. "${ShToolsCoreDir}/__LoadFuncs.noload.sh" "${ShToolsCoreDir}" "${ShToolsCoreDir}" '\'\'$'\n' &&

	LibsInitFile="${SysDir}/ShToolsLibs" &&
	AppendText "${LibsInitFile}" '# Text' \
"ShToolsTextDir='${TextDir}'
"'. "${ShToolsCoreDir}/__LoadFuncs.noload.sh" "${ShToolsCoreDir}" "${ShToolsTextDir}" '\'\'$'\n' &&

	AppendText "${SysDir}/ShTools" '# Main' \
". '${CoreInitFile}'
. '${LibsInitFile}'"$'\n' &&

	true
)

Main "$@"

