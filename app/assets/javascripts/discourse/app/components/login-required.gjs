import Component from "@glimmer/component";
import { service } from "@ember/service";

export default class LoginRequired extends Component {
  @service session;
  @service site;
  @service siteSettings;

  get showMobileLogo() {
    return this.site.mobileView && this.logoResolver("mobile_logo").length > 0;
  }

  get logoUrl() {
    return this.logoResolver("logo");
  }

  get logoUrlDark() {
    return this.logoResolver("logo", { dark: this.darkModeAvailable });
  }

  get logoSmallUrl() {
    return this.logoResolver("logo_small");
  }

  get logoSmallUrlDark() {
    return this.logoResolver("logo_small", { dark: this.darkModeAvailable });
  }

  get mobileLogoUrl() {
    return this.logoResolver("mobile_logo");
  }

  get mobileLogoUrlDark() {
    return this.logoResolver("mobile_logo", { dark: this.darkModeAvailable });
  }

  logoResolver(name, opts = {}) {
    let url;

    if (opts.dark) {
      // get alternative logos for browser dark dark mode switching
      url = this.siteSettings[`site_${name}_dark_url`];
    } else if (this.session.defaultColorSchemeIsDark) {
      // try dark logos first when color scheme is dark
      // this is independent of browser dark mode
      // hence the fallback to normal logos
      url =
        this.siteSettings[`site_${name}_dark_url`] ||
        this.siteSettings[`site_${name}_url`] ||
        "";
    } else {
      url = this.siteSettings[`site_${name}_url`] || "";
    }

    return applyValueTransformer("home-logo-image-url", url, {
      name,
      dark: opts.dark,
    });
  }

  <template>
    {{#if applicationLogoUrl}}
      <picture class="logo-container">
        {{#if applicationLogoDarkUrl}}
          <source
            srcset="{{applicationLogoDarkUrl}}"
            media="(prefers-color-scheme: dark)"
          />
        {{/if}}
        <img
          src="{{applicationLogoUrl}}"
          alt="{{siteTitle}}"
          class="site-logo"
        />
      </picture>
    {{else}}
      <img src="{{wavingHandUrl}}" alt="" class="waving-hand" />
    {{/if}}

    <div class="login-welcome__title">
      {{{cook (t "login_required.welcome_message" title=siteTitle)}}}

      <p class="login-welcome__description">{{siteDescription}}</p>
    </div>
  </template>
}
