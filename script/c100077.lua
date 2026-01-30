--阿库娅风格-幽影瞬袭
function c100077.initial_effect(c)
	aux.AddCodeList(c,100066)
	c:EnableReviveLimit()
	--Cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c100077.splimit)
	c:RegisterEffect(e0)
	--Main effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100077,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c100077.target)
	e1:SetOperation(c100077.operation)
	c:RegisterEffect(e1)

	--【新增】效果②：魔法·陷阱发动时加攻
	--只要这张卡在怪兽区域存在，每次自己把魔法·陷阱卡发动，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100077,3)) -- 请确保数据库中有对应的描述文本
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c100077.atkop)
	c:RegisterEffect(e2)
end

function c100077.splimit(e,se,sp,st)
	local sc = se:GetHandler()
	return sc and sc:IsCode(100066)
end

--判断正对面有无对方卡
function c100077.columncheck(c,ec)
	return c:IsOnField() and c:IsControler(1-ec:GetControler()) and ec:GetColumnGroup():IsContains(c)
end

function c100077.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsAttackAbove(600) then return false end
		local can_destroy=Duel.IsExistingMatchingCard(c100077.columncheck,tp,0,LOCATION_ONFIELD,1,nil,c)
		local can_move=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return can_destroy or can_move
	end

	local can_destroy=Duel.IsExistingMatchingCard(c100077.columncheck,tp,0,LOCATION_ONFIELD,1,nil,c)
	local can_move=Duel.GetLocationCount(tp,LOCATION_MZONE)>0

	if can_destroy and can_move then
		local opt=Duel.SelectOption(tp,aux.Stringid(100077,1),aux.Stringid(100077,2))
		e:SetLabel(opt)
	elseif can_move then
		Duel.SelectOption(tp,aux.Stringid(100077,1))
		e:SetLabel(0)
	elseif can_destroy then
		Duel.SelectOption(tp,aux.Stringid(100077,2))
		e:SetLabel(1)
	end
end

function c100077.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

	--发动成功时，先支付-600攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)

	local opt=e:GetLabel()
	if opt==0 then
		--移动
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		local nseq=math.log(zone,2)
		Duel.MoveSequence(c,nseq)
	else
		--破坏
		local g=Duel.GetMatchingGroup(c100077.columncheck,tp,0,LOCATION_ONFIELD,nil,c)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,1,nil)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end

--【新增】效果②的处理函数
function c100077.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：
	-- 1. 发动者是自己 (rp==tp)
	-- 2. 效果类型是“卡的发动” (EFFECT_TYPE_ACTIVATE) 而非单纯的效果发动
	-- 3. 卡片类型是魔法或陷阱 (TYPE_SPELL+TYPE_TRAP)
	if rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 可选：给个卡片闪烁的提示，让玩家知道加攻了
		Duel.Hint(HINT_CARD,0,100077) 
	end
end