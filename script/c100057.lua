-- 永续魔法卡 c100057
function c100057.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c100057.condition)
	e1:SetTarget(c100057.target)
	e1:SetOperation(c100057.activate)
	c:RegisterEffect(e1)

	-- Change Race
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE, 0)
	e2:SetTarget(c100057.racetg)
	e2:SetValue(c100057.raceval)
	c:RegisterEffect(e2)
end

-- ①：自己场上有「迪士尼」怪兽存在时才能发动。
function c100057.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x209)  -- 迪士尼怪兽为0x209
end

function c100057.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c100057.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- 选择种族
function c100057.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local race=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(race)
end

-- ①：发动时宣言1个种族
function c100057.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race=e:GetLabel()
	c:RegisterFlagEffect(100057,RESET_EVENT+RESETS_STANDARD,0,1,race)
	c:SetHint(CHINT_RACE,race) -- 设置卡片的提示种族
end

-- ②：只要这张卡在场上存在，自己场上的全部表侧表示的怪兽变成宣言的种族
function c100057.racetg(e,c)
	return c:IsFaceup() and c:IsControler(e:GetHandlerPlayer())
end

function c100057.raceval(e,c)
	return e:GetHandler():GetFlagEffectLabel(100057)
end

