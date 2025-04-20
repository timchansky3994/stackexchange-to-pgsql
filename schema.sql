CREATE SCHEMA IF NOT EXISTS StackExchange;

SET search_path TO StackExchange, public;

CREATE TABLE Users (
	Id SERIAL PRIMARY KEY,
	Reputation INT NOT NULL,
	CreationDate TIMESTAMP NOT NULL,
	DisplayName TEXT,
	LastAccessDate TIMESTAMP NOT NULL,
	WebsiteUrl TEXT,
	Location TEXT,
	AboutMe TEXT,
	Views INT NOT NULL,
	UpVotes INT NOT NULL,
	DownVotes INT NOT NULL,
	AccountId INT
);
CREATE TABLE Badges (
	Id SERIAL PRIMARY KEY,
	UserId INT NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
	Name TEXT NOT NULL,
	Date TIMESTAMP NOT NULL,
	Class SMALLINT NOT NULL,
	TagBased BOOLEAN NOT NULL
);
CREATE INDEX idx_badges_userid ON Badges(UserId);
CREATE TABLE Posts (
    Id INT PRIMARY KEY,
    PostTypeId SMALLINT NOT NULL,
    AcceptedAnswerId INT REFERENCES Posts(Id) ON DELETE SET NULL,
    ParentId INT REFERENCES Posts(Id) ON DELETE SET NULL,
    CreationDate TIMESTAMP NOT NULL,
    DeletionDate TIMESTAMP,
    Score INT NOT NULL,
    ViewCount INT,
    Body TEXT,
    OwnerUserId INT REFERENCES Users(Id) ON DELETE SET NULL,
    OwnerDisplayName TEXT,
    LastEditorUserId INT REFERENCES Users(Id) ON DELETE SET NULL,
    LastEditorDisplayName TEXT,
    LastEditDate TIMESTAMP,
    LastActivityDate TIMESTAMP,
    Title TEXT,
    Tags TEXT,
    AnswerCount INT,
    CommentCount INT,
    FavoriteCount INT,
    ClosedDate TIMESTAMP,
    CommunityOwnedDate TIMESTAMP,
	ContentLicense TEXT
);
CREATE INDEX idx_posts_owneruserid ON Posts(OwnerUserId);
CREATE INDEX idx_posts_parentid ON Posts(ParentId);
CREATE TABLE PostLinks (
    Id INT PRIMARY KEY,
    CreationDate TIMESTAMP NOT NULL,
    PostId INT NOT NULL REFERENCES Posts(Id) ON DELETE CASCADE,
    RelatedPostId INT NOT NULL REFERENCES Posts(Id) ON DELETE CASCADE,
    LinkTypeId SMALLINT NOT NULL
);
CREATE TABLE PostHistory (
    Id INT PRIMARY KEY,
    PostHistoryTypeId SMALLINT NOT NULL,
    PostId INT NOT NULL REFERENCES Posts(Id) ON DELETE CASCADE,
    RevisionGUID UUID NOT NULL,
    CreationDate TIMESTAMP NOT NULL,
    UserId INT REFERENCES Users(Id) ON DELETE SET NULL,
    UserDisplayName TEXT,
    Comment TEXT,
    Text TEXT,
	ContentLicense TEXT
);
CREATE INDEX idx_posthistory_postid ON PostHistory(PostId);
CREATE TABLE Votes (
	Id SERIAL PRIMARY KEY,
	PostId INT NOT NULL REFERENCES Posts(Id) ON DELETE CASCADE,
	VoteTypeId SMALLINT NOT NULL,
	UserId INT REFERENCES Users(Id) ON DELETE SET NULL,
	CreationDate TIMESTAMP,
	BountyAmount INT
);
CREATE INDEX idx_votes_postid ON Votes(PostId);
CREATE INDEX idx_votes_userid ON Votes(UserId);
CREATE TABLE Tags (
    Id INT PRIMARY KEY,
    TagName TEXT NOT NULL,
    Count INT NOT NULL,
    ExcerptPostId INT REFERENCES Posts(Id) ON DELETE SET NULL,
    WikiPostId INT REFERENCES Posts(Id) ON DELETE SET NULL
);
CREATE INDEX idx_tags_tagname ON Tags(TagName);
CREATE TABLE Comments (
    Id INT PRIMARY KEY,
    PostId INT NOT NULL REFERENCES Posts(Id) ON DELETE CASCADE,
    Score INT NOT NULL,
    Text TEXT NOT NULL,
    CreationDate TIMESTAMP NOT NULL,
    UserDisplayName TEXT,
    UserId INT REFERENCES Users(Id) ON DELETE SET NULL
);
CREATE INDEX idx_comments_postid ON Comments(PostId);