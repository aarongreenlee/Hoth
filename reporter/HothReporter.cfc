component
{
	variables.Config = new HothConfig();

	VARIABLES._NAME = variables.Config.getVersion();

	public struct function loadIndex() {
		local.IndexPath = variables.Config.getPath('exceptionReport');

		lock name=VARIABLES._NAME timeout=variables.Config.getTimeToLock() type="readonly" {
			local.Index = fileRead(local.IndexPath);
		}

		if (len(local.Index) == 0)
			writeDump(var='There are no exceptions on disk.', abort=true);

		if (!isJSON(local.Index))
			writeDump(var='Index is NOT JSON', abort=true);

		return deserializeJSON(local.index);
	}

	public array function sortIndex(key='count',order='desc',index) {
		local.temp = {};

		if (!structKeyExists(arguments, 'index'))
			arguments.index = loadIndex();

		for (local.k in arguments.index) {
			local.value = arguments.index[ local.k ][arguments.key];
			// Save the key
			arguments.index[ local.k ].index = local.k;
			local.temp[ local.value & '.' & randRange(1,999) ] = arguments.index[ local.k ];
		}

		local.sortedKeys = structKeyArray(local.temp);
		arraySort(local.sortedKeys, "numeric", arguments.order);

		local.result = [];
		local.n = arrayLen(local.sortedKeys);
		for (local.i = 1; local.i <= local.n; local.i++)
			arrayAppend(local.result, local.temp[ local.sortedKeys[local.i] ]);

		return local.result;
	}

	public struct function loadDetail(index) {
		local.basePath = variables.Config.getPath('exceptions') & '/' & arguments.index & '.log';

		if (fileExists(local.basePath))
			local.contents = fileRead(local.basePath);
		else
			return { HothError = 'No Detail Found'};

		if (!isJSON(local.contents))
			return { HothError = 'Detail Not JSON!'};

		return deserializeJSON(local.contents);
	}
}