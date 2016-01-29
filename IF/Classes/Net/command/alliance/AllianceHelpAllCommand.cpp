//
//  AllianceHelpAllCommand.cpp
//  IF
//
//  Created by ganxiaohua on 14-7-18.
//
//

#include "AllianceHelpAllCommand.h"

bool AllianceHelpAllCommand::handleRecieve(cocos2d::CCDictionary *dict)
{
    if (dict->valueForKey("cmd")->compare(ALLIANCE_AL_HELP_ALL) != 0)
        return false;
    
    CCDictionary *params=_dict(dict->objectForKey("params"));
    if (!params) {
        return false;
    }
    const CCString *pStr = params->valueForKey("errorCode");
    if (pStr->compare("")!=0) {
        CCCommonUtils::flyText(_lang(pStr->getCString()));
    }else{
        
        callSuccess(NetResult::create());
    }
    return true;
}