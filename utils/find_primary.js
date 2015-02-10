rs.status().members.every(function(member) {
    if (member.stateStr == 'PRIMARY') {
        print(member.name)
        return false
    }
    return true
})
