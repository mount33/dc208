package io.branch.referral;

import android.app.Application;
import android.content.Context;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Date;

import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.Defines;
import io.branch.referral.PrefHelper;
import io.branch.referral.ServerRequest;
import io.branch.referral.ServerResponse;

/**
 * * <p>
 * The server request for getting referral code. Handles request creation and execution.
 * </p>
 */
class ServerRequestGetReferralCode extends ServerRequest {
    Branch.BranchReferralInitListener callback_;

    /**
     * <p>Create an instance of ServerRequestGetReferralCode to get the referral code generated by the Branch servers.</p>
     *
     * @param context         Current {@link Application} context
     * @param prefix          A {@link String} containing the developer-specified prefix code to
     *                        be applied to the start of a referral code. e.g. for code OFFER4867,
     *                        the prefix would be "OFFER".
     * @param amount          An {@link Integer} value of credits associated with this referral code.
     * @param expiration      Optional expiration {@link Date} of the offer code.
     * @param bucket          A {@link String} value containing the name of the referral bucket
     *                        that the code will belong to.
     * @param calculationType The type of referral calculation. i.e.
     *                        {@link #LINK_TYPE_UNLIMITED_USE} or
     *                        {@link #LINK_TYPE_ONE_TIME_USE}
     * @param location        The user to reward for applying the referral code.
     *                        <p/>
     *                        <p>Valid options:</p>
     *                        <p/>
     *                        <ul>
     *                        <li>{@link #REFERRAL_CODE_LOCATION_REFERREE}</li>
     *                        <li>{@link #REFERRAL_CODE_LOCATION_REFERRING_USER}</li>
     *                        <li>{@link #REFERRAL_CODE_LOCATION_BOTH}</li>
     *                        </ul>
     * @param callback        A {@link Branch.BranchReferralInitListener} callback instance that will
     *                        trigger actions defined therein upon receipt of a response to a
     *                        referral code request.
     */
    public ServerRequestGetReferralCode(Context context, String prefix, int amount, String expiration,
                                        String bucket, int calculationType, int location, Branch.BranchReferralInitListener callback) {
        super(context, Defines.RequestPath.GetReferralCode.getPath());
        callback_ = callback;

        JSONObject post = new JSONObject();
        try {
            post.put(Defines.Jsonkey.IdentityID.getKey(), prefHelper_.getIdentityID());
            post.put(Defines.Jsonkey.DeviceFingerprintID.getKey(), prefHelper_.getDeviceFingerPrintID());
            post.put(Defines.Jsonkey.SessionID.getKey(), prefHelper_.getSessionID());
            if (!prefHelper_.getLinkClickID().equals(PrefHelper.NO_STRING_VALUE)) {
                post.put(Defines.Jsonkey.LinkClickID.getKey(), prefHelper_.getLinkClickID());
            }
            post.put(Defines.Jsonkey.CalculationType.getKey(), calculationType);
            post.put(Defines.Jsonkey.Location.getKey(), location);
            post.put(Defines.Jsonkey.Type.getKey(), Branch.REFERRAL_CODE_TYPE);
            post.put(Defines.Jsonkey.CreationSource.getKey(), Branch.REFERRAL_CREATION_SOURCE_SDK);
            post.put(Defines.Jsonkey.Amount.getKey(), amount);
            post.put(Defines.Jsonkey.Bucket.getKey(), bucket != null ? bucket : Branch.REFERRAL_BUCKET_DEFAULT);
            if (prefix != null && prefix.length() > 0) {
                post.put(Defines.Jsonkey.Prefix.getKey(), prefix);
            }
            if (expiration != null) {
                post.put(Defines.Jsonkey.Expiration.getKey(), expiration);
            }
            setPost(post);
        } catch (JSONException ex) {
            ex.printStackTrace();
            constructError_ = true;
        }
    }

    public ServerRequestGetReferralCode(Context context, Branch.BranchReferralInitListener callback) {
        super(context, Defines.RequestPath.GetReferralCode.getPath());
        JSONObject post = new JSONObject();
        try {
            post.put(Defines.Jsonkey.IdentityID.getKey(), prefHelper_.getIdentityID());
            post.put(Defines.Jsonkey.DeviceFingerprintID.getKey(), prefHelper_.getDeviceFingerPrintID());
            post.put(Defines.Jsonkey.SessionID.getKey(), prefHelper_.getSessionID());
            if (!prefHelper_.getLinkClickID().equals(PrefHelper.NO_STRING_VALUE)) {
                post.put(Defines.Jsonkey.LinkClickID.getKey(), prefHelper_.getLinkClickID());
            }
            setPost(post);
        } catch (JSONException ex) {
            ex.printStackTrace();
            constructError_ = true;
        }
    }


    public ServerRequestGetReferralCode(String requestPath, JSONObject post, Context context) {
        super(requestPath, post, context);
    }

    @Override
    public void onRequestSucceeded(ServerResponse resp, Branch branch) {
        if (callback_ != null) {
            try {
                JSONObject json;
                BranchError error = null;
                // check if a valid referral code json is returned
                if (!resp.getObject().has(Branch.REFERRAL_CODE)) {
                    json = new JSONObject();
                    json.put("error_message", "Failed to get referral code");
                    error = new BranchError("Trouble retrieving the referral code.", BranchError.ERR_BRANCH_DUPLICATE_REFERRAL_CODE);
                } else {
                    json = resp.getObject();
                }
                callback_.onInitFinished(json, error);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

    }

    @Override
    public void handleFailure(int statusCode) {
        if (callback_ != null) {
            callback_.onInitFinished(null, new BranchError("Trouble retrieving the referral code.", statusCode));
        }
    }

    @Override
    public boolean handleErrors(Context context) {
        if (!super.doesAppHasInternetPermission(context)) {
            callback_.onInitFinished(null, new BranchError("Trouble retrieving the referral code.", BranchError.ERR_NO_INTERNET_PERMISSION));
            return true;
        }
        return false;
    }

    @Override
    public boolean isGetRequest() {
        return false;
    }

    @Override
    public void clearCallbacks() {
        callback_ = null;
    }
}
