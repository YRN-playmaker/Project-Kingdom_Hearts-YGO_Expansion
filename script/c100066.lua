function c100066.initial_effect(c)
	-- 速攻魔法主效果：选择1个可发动的选项执行
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,100066)
	e1:SetTarget(c100066.target)
	e1:SetOperation(c100066.activate)
	c:RegisterEffect(e1)
end

function c100066.thfilter1(c)
	return c:IsSetCard(0x210) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function c100066.thfilter2(c)
	return c:IsCode(100025) and c:IsAbleToHand()
end
function c100066.cfilter(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and c:IsSetCard(0x208) and not c:IsType(TYPE_TOKEN) and c:IsReleasable()
		and Duel.IsExistingMatchingCard(c100066.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,lv)
end
function c100066.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x20d) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end

function c100066.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(c100066.thfilter1,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(c100066.thfilter2,tp,LOCATION_DECK,0,1,nil)
	local b3=false
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local rg=Duel.GetMatchingGroup(function(c)
			return c100066.cfilter(c,e,tp)
		end,tp,LOCATION_MZONE,0,nil)
		b3=rg:GetCount()>0
	end

	if chk==0 then return b1 or b2 or b3 end

	local ops = {}
	local idx = {}
	if b1 then table.insert(ops, aux.Stringid(100066,0)) table.insert(idx, 0) end
	if b2 then table.insert(ops, aux.Stringid(100066,1)) table.insert(idx, 1) end
	if b3 then table.insert(ops, aux.Stringid(100066,2)) table.insert(idx, 2) end

	local sel=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(idx[sel+1])

	if idx[sel+1]==0 or idx[sel+1]==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	end
end

function c100066.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		-- ①：检索键刃装备
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c100066.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif sel==1 then
		-- ②：检索键刃变形
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c100066.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif sel==2 then
		-- ③：解放键刃使 → 特招风格怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local rg=Duel.SelectReleaseGroup(tp,function(c)
			return c100066.cfilter(c,e,tp)
		end,1,1,nil)
		if #rg==0 then return end
		local lv=rg:GetFirst():GetLevel()
		Duel.Release(rg,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c100066.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,lv)
		if #sg>0 then
			local tc=sg:GetFirst()
			if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
