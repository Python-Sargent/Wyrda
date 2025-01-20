function range(table)
    local size = #table
    local st = 0
    local ed = 0
    local step = 1


    if size > 3 then
        print('Error: Extra argument, expected 3 or less than 3 arguments!')
        return
    end


    if size  <= 0 then
        print('Error: No arguments given! Expected atleast 1 or 3 arguments')
        return
    end


    if size == 1 then
        st = 0
        ed = table[1]
        step = 1
    end


    if size == 2 then
        st = table[1]
        ed = table[2]
        step = 1
    end


    if size == 3 then
        st = table[1]
        ed = table[2]
        step = table[3]
    end


    return function()
        st = st + step
        if st > ed then
            return nil
        else
            return st
        end
    end
end