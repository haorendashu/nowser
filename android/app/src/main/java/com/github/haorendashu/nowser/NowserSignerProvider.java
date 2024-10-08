package com.github.haorendashu.nowser;

import com.nt4f04und.android_content_provider.AndroidContentProvider;
import org.jetbrains.annotations.NotNull;

public class NowserSignerProvider extends AndroidContentProvider {

    @NotNull
    @Override
    public String getAuthority() {
        return "com.github.haorendashu.nowser.SIGN_EVENT;com.github.haorendashu.nowser.NIP04_ENCRYPT;com.github.haorendashu.nowser.NIP04_DECRYPT;com.github.haorendashu.nowser.NIP44_ENCRYPT;com.github.haorendashu.nowser.NIP44_DECRYPT;com.github.haorendashu.nowser.GET_PUBLIC_KEY";
    }

    @NotNull
    @Override
    public String getEntrypointName() {
        return "nowserSignerProviderEntrypoint";
    }

}
