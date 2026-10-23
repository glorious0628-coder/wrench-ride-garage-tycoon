# Topic: Roblox server facts for choosing a multiplayer model (official docs only: create.roblox.com, devforum official announcements)

You MUST use web search/fetch and cite create.roblox.com pages (quote the exact sentence). Answer each with: fact | short quote | link | confidence.
1. Reserved servers (TeleportService:ReserveServerAsync, TeleportOptions.ShouldReserveServer / ReservedServerAccessCode): can a friend use the Roblox app "Join" (join friend) button to follow a player who is inside a reserved server? Can they be found by GetPlayerPlaceInstanceAsync / TeleportToPlaceInstance? How long does a reserved server/access code live? Who can enter?
2. Private servers (paid/free "Private Servers" / VIP servers): rules, who can join, can the experience make them free, PrivateServerId / PrivateServerOwnerId, are they reachable by friends' Join button.
3. SocialService:PromptGameInvite / ExperienceInviteOptions: when a friend accepts an invite, do they land in the inviter's same server (instance)? Does that work if the inviter is in a reserved server? LaunchData / Player:GetJoinData() handling.
4. TeleportService limits and failure handling (TeleportInitFailed, retry guidance, rate limits, teleporting groups with TeleportAsync and a player list, max players per teleport).
5. Players.MaxPlayers / server size settings in Creator Dashboard (max allowed), "Preferred players" / server fill settings, social server fill (friends placed together).
6. Player:IsFriendsWith(userId) (yields? rate limits?), Players:GetFriendsAsync.
7. Any official guidance or feature about "personal servers" or "solo/private instances" for tycoon games, and the "Join friend" behavior in public servers when the server is full.
Answer in Korean, short, table + links. Mark unconfirmed items as (확인 못 함).
