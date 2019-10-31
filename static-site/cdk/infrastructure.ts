#!/usr/bin/env node
import cdk = require('@aws-cdk/core');
import { StaticSite } from './static-site';

interface TriviaGameInfrastructureStackProps extends cdk.StackProps {
    domainName: string;
    siteSubDomain: string;
}

class TriviaGameInfrastructureStack extends cdk.Stack {
    constructor(parent: cdk.App, name: string, props: TriviaGameInfrastructureStackProps) {
        super(parent, name, props);

        new StaticSite(this, 'StaticSite', {
            domainName: props.domainName,
            siteSubDomain: props.siteSubDomain
        });
   }
}

const app = new cdk.App();
new TriviaGameInfrastructureStack(app, 'TriviaGameStaticSiteInfraTest', {
    domainName: 'fspike.com',
    siteSubDomain: 'test',
    env: { account: process.env['CDK_DEFAULT_ACCOUNT'], region: 'ap-southeast-2' }
});
new TriviaGameInfrastructureStack(app, 'TriviaGameStaticSiteInfraProd', {
    domainName: 'fspike.com',
    siteSubDomain: 'www',
    env: { account: process.env['CDK_DEFAULT_ACCOUNT'], region: 'ap-southeast-2' }
});
app.synth();