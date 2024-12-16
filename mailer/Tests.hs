{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module Main where

import Data.Aeson ((.=), object)
import NeatInterpolation
import Test.Hspec

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.HashMap.Strict as M

import Types
import Render

space :: T.Text
space = " "

commonTxnAddr :: T.Text
commonTxnAddr = "foo@example.org"

commonTxnRecip :: Address
commonTxnRecip = Address (Just "foo") commonTxnAddr

commonTxnMail :: TxnMail
commonTxnMail = TxnMail
    { txnEmailType = "unknown"
    , txnTo = [commonTxnRecip]
    , txnVariables = object []
    , txnPersonalVariables = M.empty
    }

resetPassword :: TxnMail
resetPassword = commonTxnMail
    { txnEmailType = "reset-password"
    , txnVariables = object
        [ "BASE_URL" .= T.pack "https://shabitica.example.org"
        , "PASSWORD_RESET_LINK" .= T.pack
              "https://example.org/.../reset-password-set-new-one?code=123456"
        ]
    , txnPersonalVariables = M.singleton commonTxnAddr $ object
        [ "RECIPIENT_NAME" .= T.pack "lostone"
        , "RECIPIENT_UNSUB_URL" .= T.pack "/email/unsubscribe?code=1234"
        ]
    }

addNewline :: TL.Text -> TL.Text
addNewline = flip TL.snoc '\n' . TL.strip

resetPasswordBody :: TL.Text
resetPasswordBody = addNewline $ TL.fromStrict [text|
    Hello lostone,

    If you requested a password reset for Shabitica, head to
    https://example.org/.../reset-password-set-new-one?code=123456 to set a
    new one. The link will expire after 24 hours.

    If you haven't requested a password reset, please ignore this email.
    --$space
    Self-hosted Habitica instance at https://shabitica.example.org/
    Unsubscribe: https://shabitica.example.org/email/unsubscribe?code=1234
|]

welcome :: TxnMail
welcome = commonTxnMail
    { txnEmailType = "welcome"
    , txnVariables = object
        ["BASE_URL" .= T.pack "https://shabitica.example.org"]
    , txnPersonalVariables = M.singleton commonTxnAddr $ object
        ["RECIPIENT_UNSUB_URL" .= T.pack "/email/unsubscribe?code=1234"]
    }

welcomeBody :: TL.Text
welcomeBody = addNewline $ TL.fromStrict [text|
    Hello stranger,

    Welcome to the self-hosted Habitica instance at
    https://shabitica.example.org/.

    To get started simply head over to https://shabitica.example.org/ and
    log in.
    --$space
    Self-hosted Habitica instance at https://shabitica.example.org/
    Unsubscribe: https://shabitica.example.org/email/unsubscribe?code=1234
|]

inviteFriend :: TxnMail
inviteFriend = commonTxnMail
    { txnEmailType = "invite-friend"
    , txnVariables = object
        [ "LINK"     .= T.pack "/static/front?groupInvite=abcdef0123456789"
        , "INVITER"  .= T.pack "foo"
        , "BASE_URL" .= T.pack "https://shabitica.example.org"
        ]
    , txnPersonalVariables = M.singleton commonTxnAddr $ object
        [ "RECIPIENT_NAME" .= T.pack "bar"
        , "RECIPIENT_UNSUB_URL" .= T.pack "/email/unsubscribe?code=1234"
        ]
    }

inviteFriendBody :: TL.Text
inviteFriendBody = addNewline $ TL.fromStrict [text|
    Hello bar,

    foo has invited you to the self-hosted Habitica instance at
    https://shabitica.example.org/.

    Please head to the following URL to accept your invitation:

    https://shabitica.example.org/static/front?groupInvite=abcdef0123456789
    --$space
    Self-hosted Habitica instance at https://shabitica.example.org/
    Unsubscribe: https://shabitica.example.org/email/unsubscribe?code=1234
|]

inviteCollectionQuest :: TxnMail
inviteCollectionQuest = commonTxnMail
    { txnEmailType = "invite-collection-quest"
    , txnVariables = object
        [ "QUEST_NAME" .= T.pack
              "Attack of the Mundane, Part 1: Dish Disaster!"
        , "INVITER"    .= T.pack "foo"
        , "BASE_URL"   .= T.pack "https://shabitica.example.org"
        , "PARTY_URL"  .= T.pack "/party"
        ]
    , txnPersonalVariables = M.singleton commonTxnAddr $ object
        [ "RECIPIENT_NAME" .= T.pack "bar"
        , "RECIPIENT_UNSUB_URL" .= T.pack "/email/unsubscribe?code=1234"
        ]
    }

inviteCollectionQuestBody :: TL.Text
inviteCollectionQuestBody = addNewline $ TL.fromStrict [text|
    Hello bar,

    You were invited to the Collection Quest Attack of the Mundane, Part 1:
    Dish Disaster!

    To join, please head over to:

    https://shabitica.example.org/party
    --$space
    Self-hosted Habitica instance at https://shabitica.example.org/
    Unsubscribe: https://shabitica.example.org/email/unsubscribe?code=1234
|]

inviteBossQuest :: TxnMail
inviteBossQuest = commonTxnMail
    { txnEmailType = "invite-boss-quest"
    , txnVariables = object
        [ "QUEST_NAME" .= T.pack "The Basi-List"
        , "INVITER"    .= T.pack "foo"
        , "BASE_URL"   .= T.pack "https://shabitica.example.org"
        , "PARTY_URL"  .= T.pack "/party"
        ]
    , txnPersonalVariables = M.singleton commonTxnAddr $ object
        [ "RECIPIENT_NAME" .= T.pack "bar"
        , "RECIPIENT_UNSUB_URL" .= T.pack "/email/unsubscribe?code=1234"
        ]
    }

inviteBossQuestBody :: TL.Text
inviteBossQuestBody = addNewline $ TL.fromStrict [text|
    Hello bar,

    You were invited to the Boss Quest The Basi-List

    To join, please head over to:

    https://shabitica.example.org/party
    --$space
    Self-hosted Habitica instance at https://shabitica.example.org/
    Unsubscribe: https://shabitica.example.org/email/unsubscribe?code=1234
|]

questStarted :: TxnMail
questStarted = commonTxnMail
    { txnEmailType = "quest-started"
    , txnVariables = object
        [ "BASE_URL"   .= T.pack "https://shabitica.example.org"
        , "PARTY_URL"  .= T.pack "/party"
        ]
    , txnPersonalVariables = M.singleton commonTxnAddr $ object
        [ "RECIPIENT_NAME" .= T.pack "bar"
        , "RECIPIENT_UNSUB_URL" .= T.pack "/email/unsubscribe?code=1234"
        ]
    }

questStartedBody :: TL.Text
questStartedBody = addNewline $ TL.fromStrict [text|
    Hello bar,

    The quest you have joined has just started. Please head over to your
    party to see the details:

    https://shabitica.example.org/party
    --$space
    Self-hosted Habitica instance at https://shabitica.example.org/
    Unsubscribe: https://shabitica.example.org/email/unsubscribe?code=1234
|]

newPm :: TxnMail
newPm = commonTxnMail
    { txnEmailType = "new-pm"
    , txnVariables = object
        [ "BASE_URL" .= T.pack "https://shabitica.example.org"
        , "SENDER"   .= T.pack "foo"
        ]
    , txnPersonalVariables = M.singleton commonTxnAddr $ object
        [ "RECIPIENT_NAME" .= T.pack "bar"
        , "RECIPIENT_UNSUB_URL" .= T.pack "/email/unsubscribe?code=1234"
        ]
    }

newPmBody :: TL.Text
newPmBody = addNewline $ TL.fromStrict [text|
    Hello bar,

    You got a new private message from foo.
    --$space
    Self-hosted Habitica instance at https://shabitica.example.org/
    Unsubscribe: https://shabitica.example.org/email/unsubscribe?code=1234
|]

main :: IO ()
main = hspec $ do
    describe "reset-password" $ do
        let rendered = snd $ renderTxnMail commonTxnRecip resetPassword

        it "has correct subject" $
            subject rendered `shouldBe` "Password Reset for Shabitica"
        it "has correct body" $
            body rendered `shouldBe` resetPasswordBody

    describe "welcome" $ do
        let rendered = snd $ renderTxnMail commonTxnRecip welcome

        it "has correct subject" $
            subject rendered `shouldBe` "Welcome to Shabitica"
        it "has correct body" $
            body rendered `shouldBe` welcomeBody

    describe "invite-friend" $ do
        let rendered = snd $ renderTxnMail commonTxnRecip inviteFriend

        it "has correct subject" $
            subject rendered `shouldBe` "Invitation to Shabitica from foo"
        it "has correct body" $
            body rendered `shouldBe` inviteFriendBody

    describe "invite-collection-quest" $ do
        let rendered = snd $ renderTxnMail commonTxnRecip inviteCollectionQuest

        it "has correct subject" $
            subject rendered `shouldBe`
                "New Collection Quest: Attack of the Mundane,"
             <> " Part 1: Dish Disaster!"
        it "has correct body" $
            body rendered `shouldBe` inviteCollectionQuestBody

    describe "invite-boss-quest" $ do
        let rendered = snd $ renderTxnMail commonTxnRecip inviteBossQuest

        it "has correct subject" $
            subject rendered `shouldBe` "New Boss Quest: The Basi-List"
        it "has correct body" $
            body rendered `shouldBe` inviteBossQuestBody

    describe "quest-started" $ do
        let rendered = snd $ renderTxnMail commonTxnRecip questStarted

        it "has correct subject" $
            subject rendered `shouldBe` "Shabitica Quest started"
        it "has correct body" $
            body rendered `shouldBe` questStartedBody

    describe "new-pm" $ do
        let rendered = snd $ renderTxnMail commonTxnRecip newPm

        it "has correct subject" $
            subject rendered `shouldBe` "New private message from foo"
        it "has correct body" $
            body rendered `shouldBe` newPmBody
