import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { and, not, or } from "truth-helpers";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import dIcon from "discourse-common/helpers/d-icon";
import DMenu from "float-kit/components/d-menu";

export default class TopicAdminMenu extends Component {
  @service adminTopicMenuButtons;
  @service currentUser;

  @action
  onRegisterApi(api) {
    this.dMenu = api;
  }

  @action
  onButtonAction(buttonAction) {
    this.args[buttonAction]?.();
    this.dMenu.close();
  }

  @action
  onExtraButtonAction(buttonAction) {
    buttonAction?.();
    this.dMenu.close();
  }

  get extraButtons() {
    return this.adminTopicMenuButtons.callbacks
      .map((callback) => {
        return callback(this.args.topic);
      })
      .filter(Boolean);
  }

  get details() {
    return this.args.topic.get("details");
  }

  get isPrivateMessage() {
    return this.args.topic.get("isPrivateMessage");
  }

  get featured() {
    return (
      !!this.args.topic.get("pinned_at") || this.args.topic.get("isBanner")
    );
  }

  get visible() {
    return this.args.topic.get("visible");
  }

  get canDelete() {
    return this.details.get("can_delete");
  }

  get canRecover() {
    return this.details.get("can_recover");
  }

  get archived() {
    return this.args.topic.get("archived");
  }

  get topicModerationHistoryUrl() {
    return `/review?topic_id=${this.args.topic.id}&status=all`;
  }

  <template>
    <span class="topic-admin-menu-button-container">
      <span class="topic-admin-menu-button">
        <DMenu
          @onRegisterApi={{this.onRegisterApi}}
          @triggerClass="toggle-admin-menu"
        >
          <:trigger>
            {{dIcon "wrench"}}
          </:trigger>
          <:content>
            <div class="popup-menu topic-admin-popup-menu">
              <ul>
                <ul class="topic-admin-menu-topic">
                  {{#if
                    (or
                      this.currentUser.canManageTopic
                      this.details.can_split_merge_topic
                    )
                  }}
                    <li class="topic-admin-multi-select">
                      <DButton
                        @label="topic.actions.multi_select"
                        @action={{fn this.onButtonAction "toggleMultiSelect"}}
                        @icon="tasks"
                        class="popup-menu-btn"
                      />
                    </li>
                  {{/if}}

                  {{#if
                    (or
                      this.currentUser.canManageTopic
                      this.details.can_moderate_category
                    )
                  }}
                    {{#if this.canDelete}}
                      <li class="topic-admin-delete">
                        <DButton
                          @label="topic.actions.delete"
                          @action={{fn this.onButtonAction "deleteTopic"}}
                          @icon="far-trash-alt"
                          class="popup-menu-btn-danger"
                        />
                      </li>
                    {{else if (and this.canRecover @topic.deleted)}}
                      <li class="topic-admin-recover">
                        <DButton
                          @label="topic.actions.recover"
                          @action={{fn this.onButtonAction "recoverTopic"}}
                          @icon="undo"
                          class="popup-menu-btn"
                        />
                      </li>
                    {{/if}}
                  {{/if}}

                  {{#if (and this.currentUser this.details.can_close_topic)}}
                    <li class="topic-admin-open">
                      <DButton
                        @label={{if
                          @topic.closed
                          "topic.actions.open"
                          "topic.actions.close"
                        }}
                        @action={{fn this.onButtonAction "toggleClosed"}}
                        @icon={{if @topic.closed "unlock" "lock"}}
                        class="popup-menu-btn"
                      />
                    </li>
                  {{/if}}

                  {{#if
                    (and
                      this.details.can_pin_unpin_topic
                      (not this.isPrivateMessage)
                      (or this.visible this.featured)
                    )
                  }}
                    <li class="topic-admin-pin">
                      <DButton
                        @label={{if
                          this.featured
                          "topic.actions.unpin"
                          "topic.actions.pin"
                        }}
                        @action={{fn this.onButtonAction "showFeatureTopic"}}
                        @icon="thumbtack"
                        class="popup-menu-btn"
                      />
                    </li>
                  {{/if}}

                  {{#if
                    (and
                      this.currentUser
                      this.details.can_archive_topic
                      (not this.isPrivateMessage)
                    )
                  }}
                    <li class="topic-admin-archive">
                      <DButton
                        @label={{if
                          this.archived
                          "topic.actions.unarchive"
                          "topic.actions.archive"
                        }}
                        @action={{fn this.onButtonAction "toggleArchived"}}
                        @icon="folder"
                        class="popup-menu-btn"
                      />
                    </li>
                  {{/if}}

                  {{#if this.details.can_toggle_topic_visibility}}
                    <li class="topic-admin-visible">
                      <DButton
                        @label={{if
                          this.visible
                          "topic.actions.invisible"
                          "topic.actions.visible"
                        }}
                        @action={{fn this.onButtonAction "toggleVisibility"}}
                        @icon={{if this.visible "far-eye-slash" "far-eye"}}
                        class="popup-menu-btn"
                      />
                    </li>
                  {{/if}}

                  {{#if
                    (and
                      this.currentUser.canManageTopic
                      this.details.can_convert_topic
                    )
                  }}
                    <li class="topic-admin-convert">
                      <DButton
                        @label={{if
                          this.isPrivateMessage
                          "topic.actions.make_public"
                          "topic.actions.make_private"
                        }}
                        @action={{fn
                          this.onButtonAction
                          (if
                            this.isPrivateMessage
                            "convertToPublicTopic"
                            "convertToPrivateMessage"
                          )
                        }}
                        @icon={{if this.isPrivateMessage "comment" "envelope"}}
                        class="popup-menu-btn"
                      />
                    </li>
                  {{/if}}
                </ul>

                <ul class="topic-admin-menu-time">
                  {{#if this.currentUser.canManageTopic}}
                    <li class="admin-topic-timer-update">
                      <DButton
                        @label="topic.actions.timed_update"
                        @action={{fn this.onButtonAction "showTopicTimerModal"}}
                        @icon="far-clock"
                        class="popup-menu-btn"
                      />
                    </li>

                    {{#if this.currentUser.staff}}
                      <li class="topic-admin-change-timestamp">
                        <DButton
                          @label="topic.change_timestamp.title"
                          @action={{fn
                            this.onButtonAction
                            "showChangeTimestamp"
                          }}
                          @icon="calendar-alt"
                          class="popup-menu-btn"
                        />
                      </li>
                    {{/if}}

                    <li class="topic-admin-reset-bump-date">
                      <DButton
                        @label="topic.actions.reset_bump_date"
                        @action={{fn this.onButtonAction "resetBumpDate"}}
                        @icon="anchor"
                        class="popup-menu-btn"
                      />
                    </li>

                    <li class="topic-admin-slow-mode">
                      <DButton
                        @label="topic.actions.slow_mode"
                        @action={{fn
                          this.onButtonAction
                          "showTopicSlowModeUpdate"
                        }}
                        @icon="hourglass-start"
                        class="popup-menu-btn"
                      />
                    </li>
                  {{/if}}
                </ul>

                <ul class="topic-admin-menu-undefined">
                  {{#if this.currentUser.staff}}
                    <li class="topic-admin-moderation-history">
                      <DButton
                        @label="review.moderation_history"
                        @href={{this.topicModerationHistoryUrl}}
                        @icon="list"
                        class="popup-menu-btn"
                      />
                    </li>
                  {{/if}}

                  {{#each this.extraButtons as |button|}}
                    <li>
                      <DButton
                        @label={{button.label}}
                        @translatedLabel={{button.translatedLabel}}
                        @icon={{button.icon}}
                        class={{concatClass "popup-menu-btn" button.className}}
                        @action={{fn this.onExtraButtonAction button.action}}
                      />
                    </li>
                  {{/each}}
                </ul>
              </ul>
            </div>
          </:content>
        </DMenu>
      </span>
    </span>
  </template>
}
