local name, Aspect_Vendors = ...;
currentMerchant = nil;

function Aspect_Vendors:ADDON_LOADED()

	if not Data or Data == nil then
		Data = {
			Items = {},
			Vendors = {},
		};
	end
	print("Aspect Vendors Loaded");


	Aspect_Vendors:Hook();

end

function Aspect_Vendors_OnEvent(self, event, ...)
	if (event == "ADDON_LOADED" and ... == "Aspect_Vendors") then
		Aspect_Vendors:ADDON_LOADED();
	elseif (event == "MERCHANT_SHOW") then
		--Aspect_Vendors:MERCHANT_SHOW();
		print("Pojawił się Vendor");
		Aspect_Vendors:MERCHANT_SHOW();
	elseif (event == "MERCHANT_UPDATE") then
		--Aspect_Vendors:MERCHANT_UPDATE();
		print("Vendor Zaktualizowany");
	end
	
end


function Aspect_Vendors:Hook()
	local function OnTooltipSetItem(tooltip, data)
		if tooltip == GameTooltip then
			--print("OnTooltipSetItem", tooltip, data)
			Aspect_Vendors:HookTooltip()
		end
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
end

function Aspect_Vendors:HookTooltip(link)
	local itemName, itemLink, id= GameTooltip:GetItem();

	local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(id)
	
	local nameID = string.lower(name);

	nameID = nameID:gsub('[%p%c%s]', '');
	nameID = nameID .. tostring(texture);
	
	print(name.. texture);
	if link ~= nil then
		h, itemID = (":"):split(link);
		if ("|Hitem"):find(link) then
			itemLink = link;
		end
		return;
	end
	if itemLink == nil then
		return;
	end
	-- get item id from the link
	_, itemID = (":"):split(itemLink);
	-- check if the item is indexed
	itemID = tostring(itemID);



	if Data.Items[nameID] == nil then
		GameTooltip:AddLine("Aspect Vendors: No Data!");
	else
		for x = 1, table.getn(Data.Items[nameID]), 1
		do
			
			GameTooltip:AddLine("Aspect Vendors: " .. Data.Items[nameID][x][2]);


		end
		
	end

	GameTooltip:Show();
end

function Aspect_Vendors:MERCHANT_SHOW()
	Aspect_Vendors:ProcessMerchant();
end

function Aspect_Vendors:ProcessMerchant()
	local unitName = UnitName("npc"); --Imię Mercha ta
	local GUID = _G.UnitGUID("npc");
	local unitTypeName, _, _, _, _, unitID = ("-"):split(GUID);

	local m = {};
	m.Located = false;
	m.GUID = GUID;
	m.UnitID = tostring(unitID);
	m.Name = unitName;

	if Data.Vendors[m.UnitID] then
		currentMerchant = Data.Vendors[m.UnitID];
		currentMerchant.NumItems = GetMerchantNumItems();
	else	
		local posY, posX, posZ, instanceID = UnitPosition("player");
		m.Y = tonumber(posY);
		m.X = tonumber(posX);
		m.Z = tonumber(posZ);
		m.InstanceID = instanceID;
		m.ZoneReal = GetRealZoneText();
		m.ZoneSub = tostring(GetSubZoneText());
		m.MapID = C_Map.GetBestMapForUnit("player");
		m.MapGroup = C_Map.GetMapGroupID(m.MapID);
		local mapPos = C_Map.GetPlayerMapPosition(m.MapID, "player");
		m.MapX, m.MapY = mapPos:GetXY();
	
		--0	Cosmic	
		--1	World	
		--2	Continent	
		--3	Zone	
		--4	Dungeon	
		--5	Micro	
		--6	Orphan	
		local info = C_Map.GetMapInfo(m.MapID);
		m.MapType = info.mapType;
		m.MapParent = info.parentMapID;
		
		m.NumItems = GetMerchantNumItems();
		m.Items = {};
	
		currentMerchant = m;
	end

	
	Aspect_Vendors:ScanMerchantItems();
end

function Aspect_Vendors:ScanMerchantItems()
	--currentMerchant to wszystko co wyżej

	local numItems = currentMerchant.NumItems;
	local missing;

	for i = 1, numItems do
		if not GetMerchantItemInfo(i) then
			missing = true;
		end
	end	
	if missing == true then
		C_Timer.After(0.1,Mercho.ScanMerchantItems);
		return;
	end

	for i = 1, numItems do
		local name, texture, price, quantity, numAvailable, isPurchasable, isUsable, extendedCost = GetMerchantItemInfo(i);
		local nameID = string.lower(name);

		nameID = nameID:gsub('[%p%c%s]', '');
		nameID = nameID .. tostring(texture);

		if Data.Items[nameID] == nil then
			a = {currentMerchant.GUID,currentMerchant.Name, currentMerchant.X, currentMerchant.Y, numAvailable ,price, quantity};
			Data.Items[nameID] = {};
			Data.Items[nameID][1] = a;
			Data.Items[nameID][1].Name = name;
		else
			for x = 1, table.getn(Data.Items[nameID]), 1
			do
				if Data.Items[nameID][x][1] ~= currentMerchant.GUID then
					a = {currentMerchant.GUID,currentMerchant.Name, currentMerchant.X, currentMerchant.Y, numAvailable ,price, quantity};
					Data.Items[nameID][x] = a;
				    Data.Items[nameID][x].Name = name;
				end
			end
			
		end
	end
end
