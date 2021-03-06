require 'spec_helper'

describe Effective::Menu do
  describe 'Effective Menus DSL' do

    it 'correctly builds a menu with items' do
      menu = Effective::Menu.new(:title => 'test').build do
        item 'AAA'
        item 'BBB'
      end

      menu.valid?.should eq true

      items = menu.menu_items.sort_by(&:lft).map { |item| [item.title, item.lft, item.rgt] }

      expect(items).to eq [
        ['Home', 1, 6],
          ['AAA', 2, 3],
          ['BBB', 4, 5]
      ]
    end

    it 'correctly builds a menu with dropdowns' do
      menu = Effective::Menu.new(:title => 'test').build do
        dropdown 'About' do
          item 'AAA'
          item 'BBB'
        end

        dropdown 'Become a Member' do
          item '111'
          item '222'
        end

        item 'XXX'
      end

      menu.valid?.should eq true

      items = menu.menu_items.sort_by(&:lft).map { |item| [item.title, item.lft, item.rgt] }

      expect(items).to eq [
        ['Home', 1, 16],
          ['About', 2, 7],
            ['AAA', 3, 4],
            ['BBB', 5, 6],
          ['Become a Member', 8, 13],
            ['111', 9, 10],
            ['222', 11, 12],
          ['XXX', 14, 15]
      ]
    end

    it 'correctly builds a menu with dropdowns inside dropdowns' do
      menu = Effective::Menu.new(:title => 'test').build do
        dropdown 'Fruit' do
          dropdown 'Red' do
            item 'Cherry'
          end

          dropdown 'Yellow' do
            item 'Banana'
          end
        end

        dropdown 'Meat' do
          item 'Beef'
          item 'Pork'
        end
      end

      menu.valid?.should eq true

      items = menu.menu_items.sort_by(&:lft).map { |item| [item.title, item.lft, item.rgt] }

      expect(items).to eq [
        ['Home', 1, 18],
          ['Fruit', 2, 11],
            ['Red', 3, 6],
              ['Cherry', 4, 5],
            ['Yellow', 7, 10],
              ['Banana', 8, 9],
          ['Meat', 12, 17],
            ['Beef', 13, 14],
            ['Pork', 15, 16]
      ]

    end

    it 'correctly renders dropdowns and items' do
      menu = Effective::Menu.new(:title => 'test').build do
        dropdown 'About' do
          item 'AAA'
          item 'BBB'
          item 'CCC'
          item 'DDD'
        end

        dropdown 'Events' do
          item 'Conferences'

          dropdown 'Workshops' do
            dropdown 'AAA' do
              item '111'
              item '222'
            end
            item 'BBB'
          end
        end
      end

      menu.valid?.should eq true

      items = menu.menu_items.sort_by(&:lft).map { |item| [item.title, item.lft, item.rgt] }

      expect(items).to eq [
        ['Home', 1, 26],
          ['About', 2, 11],
            ['AAA', 3, 4],
            ['BBB', 5, 6],
            ['CCC', 7, 8],
            ['DDD', 9, 10],
          ['Events', 12, 25],
            ['Conferences', 13, 14],
            ['Workshops', 15, 24],
              ['AAA', 16, 21],
                ['111', 17, 18],
                ['222', 19, 20],
              ['BBB', 22, 23],
      ]
    end
  end
end
