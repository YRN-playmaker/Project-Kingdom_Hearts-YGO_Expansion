--暗之回廊
--卡片密码 100083
function c100083.initial_effect(c)
	--发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100083,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c100083.target)
	e1:SetOperation(c100083.activate)
	c:RegisterEffect(e1)
end

--检测卡组里是否有场地魔法
function c100083.deckfilter(c)
	return c:IsType(TYPE_FIELD) and not c:IsForbidden()
end

--检测墓地/除外区是否有可回收的场地魔法
function c100083.gyfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end

function c100083.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(c100083.deckfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(c100083.gyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	
	if chk==0 then return b1 or b2 end
	
	local op=0
	if b1 and b2 then
		--若两处都有，让玩家选择：1=卡组操作，2=回收
		op=Duel.SelectOption(tp,aux.Stringid(100083,1),aux.Stringid(100083,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(100083,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(100083,2))+1
	end
	
	e:SetLabel(op)
	
	--根据选择设置Category提示（非必须，但有助于客户端显示）
	if op==0 then
		e:SetCategory(CATEGORY_DECKDES) 
	else
		e:SetCategory(CATEGORY_TOHAND)
	end
end

function c100083.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	
	if op==0 then
		--●效果1：卡组 -> 最上面/手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local g=Duel.SelectMatchingCard(tp,c100083.deckfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			--检查场地区域是否有卡（自己或对方）
			local field_check = Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE) > 0
			
			--如果有场地，且卡片可以加入手卡，询问玩家
			if field_check and tc:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(100083,3)) then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				--否则（或选择不加手卡）：洗牌并放回卡组最上面
				Duel.ShuffleDeck(tp)
				Duel.MoveSequence(tc,0) -- 0代表最上面
				Duel.ConfirmDecktop(tp,1)
			end
		end
		
	else
		--●效果2：墓地/除外 -> 手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c100083.gyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end