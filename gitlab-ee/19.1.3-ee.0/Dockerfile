FROM gitlab/gitlab-ee:19.1.3-ee.0

ENV GITLAB_POST_RECONFIGURE_SCRIPT="bash /import-license.sh"

ADD license.rb /license.rb
ADD import-license.sh /import-license.sh
RUN chmod +x /import-license.sh

RUN sed -i 's/restricted_attr(:plan).presence || STARTER_PLAN/restricted_attr(:plan).presence || ULTIMATE_PLAN/' /opt/gitlab/embedded/service/gitlab-rails/ee/app/models/license.rb
RUN ruby license.rb \
    && cp -f license_key.pub /opt/gitlab/embedded/service/gitlab-rails/.license_encryption_key.pub \
    && rm /license.rb